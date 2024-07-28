#!/bin/zsh

# Load tokens and unseal keys from JSON file
vault_keys=$(cat ../_setup/vault_keys.json)
dc1_root_token=$(echo "$vault_keys" | jq -r '.dc1.root_token')
dc1_unseal_key=$(echo "$vault_keys" | jq -r '.dc1.unseal_key')
dc2_root_token=$(echo "$vault_keys" | jq -r '.dc2.root_token')
dc2_unseal_key=$(echo "$vault_keys" | jq -r '.dc2.unseal_key')

# Function to configure and execute commands inside Vault pods through their services
execute_vault_command() {
  local service_name=$1
  local vault_command=$2
  echo "Executing command via service $service_name: $vault_command" >&2  # Redirecting status message to stderr
  kubectl exec -n my-vault-demo -it svc/$service_name -- sh -c "$vault_command"
}

# Enable DR on the primary Vault cluster (dc1)
enable_dr_primary() {
  local primary_commands="vault login $dc1_root_token && vault write -f sys/replication/dr/primary/enable"
  execute_vault_command vault-dc1-active "$primary_commands"
}

# Get the secondary token from the primary cluster (dc1)
get_secondary_token() {
  local secondary_token_command="vault write sys/replication/dr/primary/secondary-token id='dr-secondary' -format=json"
  local secondary_token_output=$(execute_vault_command vault-dc1-active "$secondary_token_command")
  local token=$(echo "$secondary_token_output" | jq -r '.wrap_info.token' 2>&1)  # Ensure to handle stderr in jq processing
  echo "$token"
}

# Enable DR on the secondary Vault cluster (dc2)
enable_dr_secondary() {
  local token=$1
  local secondary_commands="vault login $dc2_root_token && vault write sys/replication/dr/secondary/enable token='$token' primary_api_addr='https://vault-dc1-active.my-vault-demo.svc.cluster.local:8200' ca_file='/vault/tls/ca.crt'"
  execute_vault_command vault-dc2-active "$secondary_commands"
}

# Create a batch DR operation token
create_batch_dr_operation_token() {
  # Generate the DR operation token on the secondary cluster (Cluster B)
  local init_command="vault operator generate-root -format=json -dr-token -init"
  local init_output=$(execute_vault_command vault-dc2-active "$init_command")
  local otp=$(echo "$init_output" | jq -r '.otp')
  local nonce=$(echo "$init_output" | jq -r '.nonce')
  
  # Use the single unseal key for the primary cluster (dc1)
  local generate_command="vault operator generate-root -format=json -dr-token -nonce=$nonce $dc1_unseal_key"
  local generate_output=$(execute_vault_command vault-dc2-active "$generate_command")
  local encoded_token=$(echo "$generate_output" | jq -r '.encoded_token')

  # Decode the DR operation token
  local decode_command="vault operator generate-root -format=json -dr-token -decode=$encoded_token -otp=$otp"
  local decode_output=$(execute_vault_command vault-dc2-active "$decode_command")
  local dr_token=$(echo "$decode_output" | jq -r '.token')
  
  echo "$dr_token"
}

# Main script execution
echo "Enabling DR on Primary (dc1)..."
enable_dr_primary
sleep 5
echo "Getting Secondary Token from Primary (dc1)..."
token=$(get_secondary_token)
echo "Enabling DR on Secondary (dc2)..."
enable_dr_secondary "$token"
sleep 5

echo "Creating Batch DR Operation Token..."
dr_operation_token=$(create_batch_dr_operation_token)

# Save necessary data to a JSON file for failover script
cat <<EOF > dr_replication_data.json
{
  "dc1_root_token": "$dc1_root_token",
  "dc2_root_token": "$dc1_root_token",
  "dr_operation_token": "$dr_operation_token"
}
EOF

echo "DR replication enabled and data saved to dr_replication_data.json."

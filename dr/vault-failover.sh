#!/bin/zsh

# Load DR operation data from JSON file
dr_replication_data=$(cat dr_replication_data.json)
dc1_root_token=$(echo "$dr_replication_data" | jq -r '.dc1_root_token')
dc2_root_token=$(echo "$dr_replication_data" | jq -r '.dc2_root_token')
dr_operation_token=$(echo "$dr_replication_data" | jq -r '.dr_operation_token')

# Function to configure and execute commands inside Vault pods through their services
execute_vault_command() {
  local service_name=$1
  local vault_command=$2
  echo "Executing command via service $service_name: $vault_command" >&2  # Redirecting status message to stderr
  kubectl exec -n my-vault-demo -it svc/$service_name -- sh -c "$vault_command"
}

# Create a new DR operation token
create_dr_operation_token() {
  # Generate the DR operation token on the primary cluster (dc2)
  local init_command="vault operator generate-root -format=json -dr-token -init"
  local init_output=$(execute_vault_command vault-dc1-active "$init_command")
  local otp=$(echo "$init_output" | jq -r '.otp')
  local nonce=$(echo "$init_output" | jq -r '.nonce')
  
  # Use the single unseal key for the secondary cluster (dc1)
  local generate_command="vault operator generate-root -format=json -dr-token -nonce=$nonce $dc1_unseal_key"
  local generate_output=$(execute_vault_command vault-dc1-active "$generate_command")
  local encoded_token=$(echo "$generate_output" | jq -r '.encoded_token')

  # Decode the DR operation token
  local decode_command="vault operator generate-root -format=json -dr-token -decode=$encoded_token -otp=$otp"
  local decode_output=$(execute_vault_command vault-dc1-active "$decode_command")
  local new_dr_operation_token=$(echo "$decode_output" | jq -r '.token')
  
  echo "$new_dr_operation_token"
}

# Promote the secondary cluster (dc2) to primary
promote_secondary_to_primary() {
  local promote_command="VAULT_ADDR=https://vault-dc2-active.my-vault-demo.svc.cluster.local:8200 vault write -f sys/replication/dr/secondary/promote dr_operation_token=$dr_operation_token"
  execute_vault_command vault-dc2-active "$promote_command"
}

# Demote the primary cluster (dc1) to secondary
demote_primary_to_secondary() {
  local demote_command="VAULT_ADDR=https://vault-dc1-active.my-vault-demo.svc.cluster.local:8200 vault write -f sys/replication/dr/primary/demote"
  execute_vault_command vault-dc1-active "$demote_command"
}

# Check replication status
check_replication_status() {
  echo "Checking replication status..."
  local status_dc1_command="vault read -format=json sys/replication/status"
  execute_vault_command vault-dc1-active "$status_dc1_command"
  local status_dc2_command="vault read -format=json sys/replication/status"
  execute_vault_command vault-dc2-active "$status_dc2_command"
}

# Main script execution
echo "Checking initial replication status..."
check_replication_status
sleep 5

echo "Taking a snapshot of the primary cluster (dc1) data..."
VAULT_ADDR=https://vault-dc1.hashibank.com:443 VAULT_TOKEN=$dc1_root_token vault operator raft snapshot save ./vault-dc1-snapshot.snap

echo "Promoting secondary (dc2) to primary..."
promote_secondary_to_primary
sleep 10

echo "Waiting for vault-dc2-active to be in primary state..."
while true; do
  local status_dc2_command="vault read sys/replication/status -format=json"
  local status_dc2=$(execute_vault_command vault-dc2-active "$status_dc2_command" | jq -r '.data.dr.mode')
  if [[ "$status_dc2" == "primary" ]]; then
    echo "vault-dc2-active is now primary."
    break
  fi
  echo "Waiting for vault-dc2-active to be in primary state..."
  sleep 5
done

echo "Demoting primary (dc1) to secondary..."
demote_primary_to_secondary
sleep 5

echo "Checking replication status after failover..."
check_replication_status
sleep 5

echo "Testing access to Vault data on new primary (dc2)..."
VAULT_ADDR=https://vault-dc2.hashibank.com:443 VAULT_TOKEN=$dc1_root_token vault kv get demo-key-value/team_pipelines_secrets

echo "Creating a new DR operation token for updating dc1 to point to dc2..."
new_dr_operation_token=$(create_dr_operation_token)

echo "Pointing demoted cluster (dc1) to new primary (dc2)..."
# Generate the public key on dc1
#export DR_SECONDARY_PUB_KEY=$(execute_vault_command vault-dc1-active "vault write -field=secondary_public_key -f sys/replication/dr/secondary/generate-public-key")
export DR_SECONDARY_PUB_KEY=$(VAULT_ADDR=https://vault-dc1.hashibank.com:443 vault write -field=secondary_public_key -f sys/replication/dr/secondary/generate-public-key)
echo "DR_SECONDARY_PUB_KEY: $DR_SECONDARY_PUB_KEY"  # Debug output

# Generate a new secondary token on dc2
export CLUSTER_A_DR_SECONDARY_TOKEN=$(VAULT_ADDR=https://vault-dc2.hashibank.com:443 VAULT_TOKEN=$dc1_root_token vault write -field=token sys/replication/dr/primary/secondary-token id=dc1 secondary_public_key=$DR_SECONDARY_PUB_KEY)
echo "CLUSTER_A_DR_SECONDARY_TOKEN: $CLUSTER_A_DR_SECONDARY_TOKEN"  # Debug output

# Update dc1 to point to dc2
#execute_vault_command vault-dc1-active "VAULT_ADDR=https://vault-dc1-active.my-vault-demo.svc.cluster.local:8200 vault write sys/replication/dr/secondary/update-primary dr_operation_token=$new_dr_operation_token token=$CLUSTER_A_DR_SECONDARY_TOKEN"
VAULT_ADDR=https://vault-dc1.hashibank.com:443 vault write sys/replication/dr/secondary/update-primary dr_operation_token=$new_dr_operation_token token=$CLUSTER_A_DR_SECONDARY_TOKEN

echo "Checking replication status on cluster B..."
VAULT_TOKEN=$dc1_root_token vault read --format=json sys/replication/status

echo "Failover process completed."

# Function to configure and execute commands inside Vault pods through their services
execute_vault_command() {
  local service_name=$1
  local vault_command=$2
  echo "Executing command via service $service_name: $vault_command" >&2  # Redirecting status message to stderr
  kubectl exec -n my-vault-demo -it svc/$service_name -- sh -c "$vault_command"
}
# Configure DR on Primary Vault (dc1)
primary_commands="vault login $dc1_root_token && vault write -f sys/replication/dr/primary/enable"
execute_vault_command vault-dc1-active "$primary_commands"
sleep 5
secondary_token_command="vault write sys/replication/dr/primary/secondary-token id='dr-secondary' -format=json"
secondary_token_output=$(execute_vault_command vault-dc1-active "$secondary_token_command")
token=$(echo "$secondary_token_output" | jq -r '.wrap_info.token' 2>&1)  # Ensure to handle stderr in jq processing

# Configure DR on Secondary Vault (dc2)
secondary_commands="vault login $dc2_root_token && vault write sys/replication/dr/secondary/enable token='$token' primary_api_addr='https://vault-dc1-active.my-vault-demo.svc.cluster.local:8200' ca_file='/vault/tls/ca.crt'"
execute_vault_command vault-dc2-active "$secondary_commands"

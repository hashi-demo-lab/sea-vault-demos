#!/usr/bin/zsh

# Check if necessary environment variables are set
: "${dc1_root_token:?Need to set dc1_root_token}"
: "${dc2_root_token:?Need to set dc2_root_token}"
: "${dc1_unseal_key:?Need to set dc1_unseal_key}"

configure_vault() {
  local vault_addr=$1
  local vault_token=$2
  
  export VAULT_ADDR="${vault_addr}"
  export VAULT_TOKEN="${vault_token}"
  
  vault login "${VAULT_TOKEN}"
  if [ $? -ne 0 ]; then
    echo "Failed to log in to Vault at ${VAULT_ADDR}"
  fi
}

# Configure DR on Primary Vault (dc1)
configure_vault 'https://vault-dc1.hashibank.com:443' "${dc1_root_token}"
vault write -f sys/replication/dr/primary/enable
sleep 5
secondary_token_output=$(vault write sys/replication/dr/primary/secondary-token id="dr-secondary" -format=json)
token=$(echo "${secondary_token_output}" | jq -r '.wrap_info.token')

# Configure DR on Secondary Vault (dc2)
configure_vault 'https://vault-dc2.hashibank.com:443' "${dc2_root_token}"
vault write sys/replication/dr/secondary/enable token="${token}"

# Unseal DR nodes with Primary Vault (dc1) unseal key
for i in {1..2}; do
  pod_name="vault-dc2-$i"
  echo -e "\n\033[32mUnsealing pod: ${pod_name}\033[0m\n"
  kubectl exec "${pod_name}" -- vault operator unseal "${dc1_unseal_key}"
done
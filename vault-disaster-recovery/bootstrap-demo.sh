#!usr/bin/zsh

export VAULT_ADDR='http://localhost:32000'
export VAULT_TOKEN=$dc1_root_token
vault login $VAULT_TOKEN

vault write -f sys/replication/dr/primary/enable
sleep 5
secondary_token_output=$(vault write sys/replication/dr/primary/secondary-token id="dr-secondary" -format=json)
token=$(echo $secondary_token_output | jq -r '.wrap_info.token')

export VAULT_ADDR='http://localhost:32001'
export VAULT_TOKEN=$dc2_root_token
vault login $VAULT_TOKEN

vault write sys/replication/dr/secondary/enable token="${token}"
for i in {1..2}; do
  pod_name="vault-dc2-$i"
  echo "\n\033[32mUnsealing pod: ${pod_name}\033[0m\n"
  kubectl exec "${pod_name}" -- vault operator unseal $(eval echo "\${dc1_unseal_key}")
done
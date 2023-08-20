export VAULT_TOKEN=$dc1_root_token
export VAULT_PORT=443
export VAULT_ADDR=https://vault-dc1.hashibank.com:${VAULT_PORT}

vault login $dc1_root_token
vault secrets enable -version=2 -path=demo-key-value kv
vault kv put /demo-key-value/hashibank @data.json
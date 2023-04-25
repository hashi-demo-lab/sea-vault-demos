export VAULT_TOKEN=$dc1_root_token
export VAULT_PORT=32000
export VAULT_ADDR=http://localhost:${VAULT_PORT}

vault login $dc1_root_token
vault secrets enable -version=2 -path=demo-kv kv
vault kv put /demo-kv/hashibank @data.json


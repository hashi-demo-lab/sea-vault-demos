path "demo-key-value/data/aarons-secrets" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "demo-key-value/*" {
  capabilities = [ "list" ]
}
path "demo-key-value/data/simons-secrets" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "demo-key-value/*" {
  capabilities = [ "list" ]
}
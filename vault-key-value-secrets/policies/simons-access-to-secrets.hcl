path "demo-key-value/*" {
  capabilities = [ "read" ]
}

path "demo-key-value/simons-secrets" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
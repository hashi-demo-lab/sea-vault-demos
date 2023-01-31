path "demo-key-value/*" {
  capabilities = [ "read" ]
}

path "demo-key-value/aarons-secrets" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}
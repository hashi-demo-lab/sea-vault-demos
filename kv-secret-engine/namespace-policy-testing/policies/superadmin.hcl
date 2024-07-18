# Superadmin policy for Aaron with root-level access
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

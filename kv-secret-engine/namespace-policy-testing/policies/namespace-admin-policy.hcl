# Namespace admin policy example
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
  denied_parameters = {
    "type" = ["transit", "database"]
  }
}

path "sys/internal/ui/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "sys/internal/counters/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "sys/leases/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# deny modifying my own admin policy
path "sys/policies/namespace-admin" {
  capabilities = ["read", "list"]
}

path "sys/auth/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "sys/health" {
  capabilities = ["read"]
}

path "sys/seal-status" {
  capabilities = ["read"]
}

path "sys/internal/ui/mounts" {
  capabilities = ["list", "read"]
}

path "sys/internal/ui/mounts/secret" {
  capabilities = ["list", "read"]
}

path "sys/internal/ui/mounts/secret/*" {
  capabilities = ["list", "read"]
}

path "kv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/metadata/*" {
  capabilities = ["list"]
}

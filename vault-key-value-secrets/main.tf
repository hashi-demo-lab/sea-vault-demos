provider "vault" {
  address = var.vault_address
}

# Create a KV secrets engine
resource "vault_mount" "main" {
  path        = var.kv_secrets_mount
  type        = "kv"
  options     = { version = "2" }
  description = "Key/Value mount for Workload Identity demo"
}

# Create a secret in the KV engine
resource "vault_kv_secret_v2" "main" {
  mount = vault_mount.main.path
  name  = var.kv_secrets_name
  data_json = jsonencode(
    {
      team     = "solution engineers and architects",
      location = "sydney"
    }
  )
}
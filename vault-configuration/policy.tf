# Create a policy granting the TFC workspace access to the KV engine & AWS engine
resource "vault_policy" "main" {
  name   = "demo_policy"
  policy = <<EOT
    # Generate child tokens with Terraform provider
    path "auth/token/create" {
    capabilities = ["update"]
    }

    path "auth/token/revoke-self" {
      capabilities = ["update"]
    }

    # Used by the token to query itself
    path "auth/token/lookup-self" {
    capabilities = ["read"]
    }

    # Get secrets from KV engine
    path "${vault_kv_secret_v2.main.path}" {
      capabilities = ["list","read"]
    }

    # Get secrets from AWS engine
    path "${var.VAULT_PATH}/*" {
      capabilities = ["create", "read", "update", "patch", "delete", "list"]
    }
  EOT
}


# Create a policy granting the TFC workspace access to the KV engine & AWS engine
resource "vault_policy" "main" {
  name   = "azure_demo_policy"
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

    # Get secrets from Azure engine
    path "${var.vault_path}/*" {
      capabilities = ["read"]
    }

    # Get secrets from K/V engine
    path "demo-key-value/*" {
      capabilities = ["read"]
    }
  EOT
}
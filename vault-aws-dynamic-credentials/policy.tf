# Create a policy granting the TFC workspace access to the KV engine & AWS engine
resource "vault_policy" "main" {
  name   = "aws_demo_policy"
  policy = <<EOT

    # Allow tokens to query themselves
    path "auth/token/lookup-self" {
      capabilities = ["read"]
    }

    # Allow tokens to renew themselves
    path "auth/token/renew-self" {
      capabilities = ["update"]
    }

    # Allow tokens to revoke themselves
    path "auth/token/revoke-self" {
      capabilities = ["update"]
    }

    # Generate child tokens with Terraform provider
    path "auth/token/create" {
      capabilities = ["update"]
    }

    # Get secrets from AWS engine
    path "${var.vault_path}/*" {
      capabilities = ["read"]
    }

    # Get secrets from K/V engine
    path "demo-key-value/*" {
      capabilities = ["read"]
    }
  EOT
}


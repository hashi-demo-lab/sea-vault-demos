# Create a policy granting the TFC workspace access to the KV engine & AWS engine
resource "vault_policy" "main" {
  name   = "aws_demo_policy"
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

    # Get secrets from AWS engine
    path "demo-aws-dynamic-credentials/*" {
      capabilities = ["create", "read", "update", "patch", "delete", "list"]
    }
  EOT
}


# Create a policy granting the TFC workspace access to the KV engine & AWS engine
resource "vault_policy" "main" {
  name   = "aws_demo_policy"
  policy = <<EOT
    # Get secrets from KV engine
    path "${vault_kv_secret_v2.main.path}" {
      capabilities = ["list","read"]
    }
  EOT
}


provider "vault" {
  address = "http://localhost:8200"
}

# Create a KV secrets engine
resource "vault_mount" "futureApp" {
  path        = var.kv_secrets_mount
  type        = "kv"
  options     = { version = "2" }
  description = "KV mount for TFC OIDC demo"
}

# Create a secret in the KV engine
resource "vault_kv_secret_v2" "futureApp" {
  mount = vault_mount.futureApp.path
  name  = var.kv_secrets_key
  data_json = jsonencode(
    {
      customerName = "aaron",
      location  = "sydney"
    }
  )
}

# Create a policy granting the TFC workspace access to the KV engine
resource "vault_policy" "futureApp" {
  name = "tfc-workspace-oidc"

  policy = <<EOT
# Generate child tokens with Terraform provider
path "auth/token/create" {
capabilities = ["update"]
}

# Used by the token to query itself
path "auth/token/lookup-self" {
capabilities = ["read"]
}

# Get secrets from KV engine
path "${vault_kv_secret_v2.futureApp.path}" {
  capabilities = ["list","read"]
}

# Get secrets from AWS engine
path "aws/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

EOT
}

# Create the JWT auth method to use GitHub
resource "vault_jwt_auth_backend" "jwt" {
  description        = "JWT Backend for TFC OIDC"
  path               = "jwt"
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

# Create the JWT role tied to workspaceOne
resource "vault_jwt_auth_backend_role" "workspaceOneRole" {
  backend           = vault_jwt_auth_backend.jwt.path
  role_name         = "vault-demo-assumed-role"
  token_policies    = [vault_policy.futureApp.name]
  token_max_ttl     = "100"
  bound_audiences   = ["vault.testing"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization}:project:${var.tfc_project}:workspace:${var.tfc_workspace}:run_phase:*"
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
}


resource "vault_aws_secret_backend" "aws" {
  description       = "Demo of the AWS secrets engine"
}

resource "vault_aws_secret_backend_role" "vault_role_assumed_role_credential_type" {
  backend         = vault_aws_secret_backend.aws.path
  credential_type = "assumed_role"
  name            = "vault-demo-assumed-role"
  role_arns       = ["arn:aws:iam::258850230659:role/testrole"]
}
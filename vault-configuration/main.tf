provider "vault" {
  address = var.vault_address
}

provider "aws" {
  region = var.region
}

# Enable the JWT authentication method for TFC Workload Identity
resource "vault_jwt_auth_backend" "main" {
  description        = "JWT Backend for TFC OIDC"
  path               = "jwt"
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

resource "vault_jwt_auth_backend_role" "main" {
  backend           = vault_jwt_auth_backend.main.path
  role_name         = "vault-demo-assumed-role"
  token_policies    = [vault_policy.main.name]
  token_max_ttl     = "100"
  bound_audiences   = ["vault.testing"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization}:project:${var.tfc_project}:workspace:${var.tfc_workspace}:run_phase:*"
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
}

# Enable the GitHub authentication method
resource "vault_github_auth_backend" "github_authentication" {
  organization = "hashicorp-demo-lab"
  token_policies = [ "demo_policy" ]
}
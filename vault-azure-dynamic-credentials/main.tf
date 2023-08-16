resource "vault_azure_secret_backend" "azure" {
  use_microsoft_graph_api = true
  subscription_id         = var.subscription_id
  tenant_id               = var.tenant_id
  client_secret           = var.client_secret
  client_id               = var.client_id
}

resource "vault_azure_secret_backend_role" "generated_role" {
  backend = vault_azure_secret_backend.azure.path
  role    = "generated_role"
  ttl     = var.ttl
  max_ttl = var.max_ttl

  azure_roles {
    role_name = "Contributor"
    scope     = "/subscriptions/${var.subscription_id}"
  }
}

# Enable the JWT authentication method for TFC Workload Identity
resource "vault_jwt_auth_backend" "main" {
  description        = "Azure - JWT Backend for TFC OIDC"
  path               = "azure_jwt"
  type               = "jwt"
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

resource "vault_jwt_auth_backend_role" "main" {
  backend        = vault_jwt_auth_backend.main.path
  role_name      = "vault-demo-role"
  token_policies = [vault_policy.main.name]

  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization}:project:${var.tfc_project}:workspace:*:run_phase:*"
  }

  user_claim    = "terraform_full_workspace"
  role_type     = "jwt"
  token_max_ttl = "900"
}
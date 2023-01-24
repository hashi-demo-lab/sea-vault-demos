## Place all your terraform resources here
#  Locals at the top (if you are using them)
#  Data blocks next to resources that are referencing them
#  Reduce hard coded inputs where possible. They are used below for simplicity to show structure

/* local {
  # Local that is a map that is used for something
  example-local {
    key = value
  }
}

data "vault_auth_backend" "kubernetes" {
  namespace = var.namespace
  path      = "kubernetes"
}

resource "vault_policy" "policies" {
  namespace = var.namespace
  name      = "name"
  policy    = "policy"
} */

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


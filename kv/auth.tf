resource "vault_github_auth_backend" "example" {
  organization = "hashi-demo-lab"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
  path = "kv-userpass"

}

# Create local users
resource "vault_generic_endpoint" "aaron" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/kv-userpass/users/aaron"
  ignore_absent_fields = true
  data_json            = <<EOT
{
  "policies": ["demo-aarons-access", "demo-sea-access", "request-pki-cert" ],
  "password": "changeme"
}
EOT
}

resource "vault_generic_endpoint" "simon" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/kv-userpass/users/simon"
  ignore_absent_fields = true
  data_json            = <<EOT
{
  "policies": ["demo-simons-access", "demo-sea-access", "approve-pki-cert" ],
  "password": "changeme"
}
EOT
}

/*resource "vault_auth_backend" "userpass_IT" {
  type      = "userpass"
  namespace = "IT"
}

resource "vault_auth_backend" "userpass_IT_Prod" {
  type      = "userpass"
  namespace = "IT/IT_Prod"
}

resource "vault_auth_backend" "userpass_IT_Dev" {
  type      = "userpass"
  namespace = "IT/IT_Dev"
}

#--------------------------------------------------------------------
# Enable approle auth method in the 'education/training' namespace
#--------------------------------------------------------------------
resource "vault_auth_backend" "approle" {
  depends_on = [vault_namespace.training]
  namespace  = vault_namespace.training.path_fq
  type       = "approle"
}

# Create a role named, "test-role"
resource "vault_approle_auth_backend_role" "test-role" {
  depends_on     = [vault_auth_backend.approle]
  backend        = vault_auth_backend.approle.path
  namespace      = vault_namespace.training.path_fq
  role_name      = "test-role"
  token_policies = ["default", "admins"]
}*/
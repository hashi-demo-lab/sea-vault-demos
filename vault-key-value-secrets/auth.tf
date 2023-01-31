resource "vault_github_auth_backend" "example" {
  organization = "hashicorp-demo-lab"
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Create local users
resource "vault_generic_endpoint" "aaron" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/aaron" 
  ignore_absent_fields = true
  data_json = <<EOT
{
  "policies": ["fpe-client", "admins", "demo-aarons-access"],
  "password": "changeme"
}
EOT
}

resource "vault_generic_endpoint" "simon" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/simon"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["fpe-client", "admins", "demo-simons-access"],
  "password": "changeme"
}
EOT
}

#--------------------------------------------------------------------
# Enable approle auth method in the 'education/training' namespace
#--------------------------------------------------------------------
resource "vault_auth_backend" "approle" {
  depends_on = [vault_namespace.training]
  namespace = vault_namespace.training.path_fq
  type       = "approle"
}

# Create a role named, "test-role"
resource "vault_approle_auth_backend_role" "test-role" {
  depends_on     = [vault_auth_backend.approle]
  backend        = vault_auth_backend.approle.path
  namespace = vault_namespace.training.path_fq
  role_name      = "test-role"
  token_policies = ["default", "admins"]
}
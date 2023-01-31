resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Create local users
resource "vault_generic_endpoint" "alice" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/alice"
  ignore_absent_fields = true
  data_json            = <<EOT
  {
    "policies": ["demo-database-readwrite"],
    "password": "changeme"
  }
  EOT
}

resource "vault_generic_endpoint" "bob" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/bob"
  ignore_absent_fields = true
  data_json            = <<EOT
  {
    "policies": ["demo-database-readonly"],
    "password": "changeme"
  }
  EOT
}
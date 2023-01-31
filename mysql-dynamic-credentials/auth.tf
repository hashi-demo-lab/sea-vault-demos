resource "vault_auth_backend" "userpass" {
  type = "userpass"
  path = "demodatabase"
}

# Create local users
resource "vault_generic_endpoint" "alice" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/alice"
  ignore_absent_fields = true
  data_json = <<EOT
  {
    "policies": ["demo-database-readwrite"],
    "password": "changeme"
  }
  EOT
}

resource "vault_generic_endpoint" "bob" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/${vault_auth_backend.userpass.path}/users/bob"
  ignore_absent_fields = true
  data_json = <<EOT
  {
    "policies": ["demo-database-readonly"],
    "password": "changeme"
  }
  EOT
}
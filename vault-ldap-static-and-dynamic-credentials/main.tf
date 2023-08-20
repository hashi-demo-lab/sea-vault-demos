provider "vault" {
  address = var.vault_address
}

resource "vault_ldap_auth_backend" "ldap" {
  path           = "ldap"
  url            = "ldap://ldap-service"
  userdn         = "ou=users,dc=hashibank,dc=com"
  binddn         = "cn=admin,dc=hashibank,dc=com"
  bindpass       = "admin"
  groupdn        = "ou=groups,dc=hashibank,dc=com"
  token_policies = ["demo-aarons-access"]
}

resource "vault_ldap_secret_backend" "config" {
  path         = "my-custom-ldap"
  binddn       = "cn=admin,dc=hashibank,dc=com"
  bindpass     = "admin"
  url          = "ldap://ldap-service"
  insecure_tls = "true"
  userdn       = "ou=users,dc=hashibank,dc=com"
}

resource "vault_ldap_secret_backend_static_role" "role" {
  mount           = vault_ldap_secret_backend.config.path
  username        = "alice"
  dn              = "cn=alice,ou=users,dc=hashibank,dc=com"
  role_name       = "alice"
  rotation_period = 60
}
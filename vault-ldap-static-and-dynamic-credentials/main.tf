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
  token_policies = ["team-sea-access"]
  token_ttl = 90
}

resource "vault_ldap_secret_backend" "config" {
  path         = "ldap"
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

data "external" "password_hash" {
  program = ["./files/generate_hash.sh", "your-password-here"]
}


resource "vault_ldap_secret_backend_dynamic_role" "this" {
  for_each  = tomap({ for role in var.ldap_roles : role.role_name => role })
  mount     = vault_ldap_secret_backend.config.path
  role_name = each.value.role_name
  creation_ldif = templatefile("${path.module}/files/creation.ldif.tmpl", {
    group_names = each.value.group_names,
    password_hash = data.external.password_hash.result["passwordHash"]
  })
  deletion_ldif     = file("${path.module}/files/deletion.ldif")
  rollback_ldif     = file("${path.module}/files/rollback.ldif")
  default_ttl       = 60 * 10     # One hour
  max_ttl           = 8 * 3600 # Eight hours
  username_template = "{{printf \"%s%s%s%s\" (.DisplayName | truncate 8) (.RoleName | truncate 8) (random 20)| truncate 20}}"
}

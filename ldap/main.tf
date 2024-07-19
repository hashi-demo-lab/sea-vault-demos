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
  token_ttl = 600
}

resource "vault_ldap_auth_backend_group" "developers" {
  backend   = vault_ldap_auth_backend.ldap.path
  groupname = "developers"
  policies  = ["dev-policy"]
}

resource "vault_ldap_auth_backend_group" "testers" {
  backend   = vault_ldap_auth_backend.ldap.path
  groupname = "testers"
  policies  = ["test-policy"]
}

resource "vault_ldap_auth_backend_group" "administrators" {
  backend   = vault_ldap_auth_backend.ldap.path
  groupname = "administrators"
  policies  = ["prod-policy"]
}

resource "vault_policy" "dev_policy" {
  name = "dev-policy"

  policy = <<EOT
path "demo-pki-intermediate/issue/dev-role" {
  capabilities = ["create", "update", "read"]
}
EOT
}

resource "vault_policy" "test_policy" {
  name = "test-policy"

  policy = <<EOT
path "demo-pki-intermediate/issue/test-role" {
  capabilities = ["create", "update"]
}

path "demo-pki-intermediate/roles/test-role" {
  capabilities = ["read", "list"]
}

path "demo-pki-intermediate/roles" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_policy" "prod_policy" {
  name = "prod-policy"

  policy = <<EOT
path "demo-pki-intermediate/issue/prod-role" {
  capabilities = ["create", "update", "read"]
}

path "demo-pki-intermediate/roles/*" {
  capabilities = ["read", "list"]
}

EOT
}

resource "vault_ldap_secret_backend" "config" {
  path         = "ldap"
  binddn       = "cn=admin,dc=hashibank,dc=com"
  bindpass     = "admin"
  url          = "ldap://ldap-service"
  insecure_tls = "true"
  userdn       = "ou=users,dc=hashibank,dc=com"
}

resource "vault_ldap_secret_backend_static_role" "dev_service" {
  mount           = vault_ldap_secret_backend.config.path
  username        = "dev-service"
  dn              = "cn=dev-service,ou=users,dc=hashibank,dc=com"
  role_name       = "dev-service"
  rotation_period = 86400 # 24 hours
}

resource "vault_ldap_secret_backend_static_role" "test_service" {
  mount           = vault_ldap_secret_backend.config.path
  username        = "test-service"
  dn              = "cn=test-service,ou=users,dc=hashibank,dc=com"
  role_name       = "test-service"
  rotation_period = 86400 # 24 hours
}

resource "vault_ldap_secret_backend_static_role" "prod_service" {
  mount           = vault_ldap_secret_backend.config.path
  username        = "prod-service"
  dn              = "cn=prod-service,ou=users,dc=hashibank,dc=com"
  role_name       = "prod-service"
  rotation_period = 86400 # 24 hours
}

data "external" "password_hash" {
  program = ["./files/generate_hash.sh", "your-password-here"]
}

resource "vault_ldap_secret_backend_dynamic_role" "this" {
  for_each  = tomap({ for role in var.ldap_roles : role.role_name => role })
  mount     = vault_ldap_secret_backend.config.path
  role_name = each.value.role_name

  username_template = "dyn-service-{{truncate 8 .DisplayName}}-{{random 8}}"
  creation_ldif = templatefile("${path.module}/files/creation.ldif.tmpl", {
    role_name    = each.value.role_name,
    group_names  = each.value.group_names,
    password_hash = data.external.password_hash.result["passwordHash"]
  })
  deletion_ldif     = file("${path.module}/files/deletion.ldif")
  rollback_ldif     = file("${path.module}/files/rollback.ldif")
  
  default_ttl       = 86400     # 24 hours
  max_ttl           = 8 * 3600  # Eight hours
}

/*resource "vault_ldap_secret_backend_library_set" "service_account_library" {
  mount                        = vault_ldap_secret_backend.config.path
  name                         = "service-accounts"
  service_account_names        = ["svc-account1", "svc-account2", "svc-account3"]
  ttl                          = 3600     # 1 hour
  max_ttl                      = 86400    # 24 hours
  disable_check_in_enforcement = false
}*/
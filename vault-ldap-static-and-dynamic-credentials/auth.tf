resource "vault_ldap_auth_backend" "ldap" {
  path           = "ldap"
  url            = "ldap://ldap-service"
  userdn         = "ou=users,dc=hashibank,dc=com"
  binddn         = "cn=admin,dc=hashibank,dc=com"
  bindpass       = "admin"
  groupdn        = "ou=groups,dc=hashibank,dc=com"
  token_policies = ["demo-aarons-access"]
}
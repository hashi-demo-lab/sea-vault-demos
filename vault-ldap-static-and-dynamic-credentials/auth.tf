resource "vault_ldap_auth_backend" "ldap" {
  path     = "ldap"
  url      = "ldap://host.docker.internal"
  userdn   = "ou=users,dc=example,dc=org"
  binddn   = "cn=admin,dc=example,dc=org"
  bindpass = "admin"
  groupdn  = "ou=groups,dc=example,dc=org"
  token_policies = [ "demo-aarons-access" ]
}
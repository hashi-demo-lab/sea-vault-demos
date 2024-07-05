resource "vault_policy" "demo-pki-policy" {
  name   = "pki"
  policy = file("${path.module}/policies/pki.hcl")
}

resource "vault_policy" "request-pki-cert" {
  name   = "request-pki-cert"
  policy = file("${path.module}/policies/request-pki-cert.hcl")
}

resource "vault_policy" "approve-pki-cert" {
  name   = "approve-pki-cert"
  policy = file("${path.module}/policies/approve-pki-cert.hcl")
}

data "vault_identity_entity" "simon" {
  alias_name           = "simon"
  alias_mount_accessor = "auth_userpass_a5d744cf"
}

resource "vault_identity_group" "acct_manager" {
  name = "acct_manager"
  type = "internal"

  policies = [
    vault_policy.approve-pki-cert.name,
  ]
}

resource "vault_identity_group_member_entity_ids" "members" {
  # Correctly reference the entity ID from the data source and group ID from the resource
  member_entity_ids = ["${data.vault_identity_entity.simon.id}"]
  group_id          = vault_identity_group.acct_manager.id
}
resource "vault_policy" "demo-database-readonly-policy" {
  name   = "pki"
  policy = file("policies/pki.hcl")
}
resource "vault_policy" "demo-pki-policy" {
  name   = "pki"
  policy = file("${path.module}/policies/pki.hcl")
}
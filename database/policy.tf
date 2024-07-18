resource "vault_policy" "demo-database-readonly-policy" {
  name   = "demo-database-readonly"
  policy = file("policies/readonly-policy.hcl")
}

resource "vault_policy" "demo-database-readwrite-policy" {
  name   = "demo-database-readwrite"
  policy = file("policies/readwrite-policy.hcl")
}
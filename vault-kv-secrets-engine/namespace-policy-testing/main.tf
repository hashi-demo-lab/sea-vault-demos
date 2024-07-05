# Define the variable for Vault address
variable "vault_address" {
  type        = string
  description = "Vault address"
}

# Use the variable in the provider configuration
provider "vault" {
  address = var.vault_address
}

# Create the userpass auth backend in the root namespace
resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

# Create the namespace
resource "vault_namespace" "IT" {
  path = "IT"
}

# Enable the userpass auth backend in the IT namespace
resource "vault_auth_backend" "userpass_IT" {
  namespace = vault_namespace.IT.path
  type      = "userpass"
}

# Create local users in the root namespace
resource "vault_generic_endpoint" "aaron" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/aaron"
  ignore_absent_fields = true
  data_json            = <<EOT
{
  "policies": ["superadmin"],
  "password": "changeme"
}
EOT
}

resource "vault_generic_endpoint" "simon" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/simon"
  ignore_absent_fields = true
  data_json            = <<EOT
{
  "policies": ["namespace-admins"],
  "password": "changeme"
}
EOT
}

# Define the superadmin policy for Aaron
resource "vault_policy" "superadmin_policy" {
  name   = "superadmin"
  policy = file("policies/superadmin.hcl")
}

# Define the namespace admin policy within the IT namespace
resource "vault_policy" "namespace_admin_policy_IT" {
  namespace = vault_namespace.IT.path
  name      = "namespace-admins"
  policy    = file("policies/namespace-admin-policy.hcl")
}

# Assign policies to users in the root namespace
resource "vault_generic_endpoint" "aaron_policy_assign" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/aaron"
  ignore_absent_fields = true
  data_json            = <<EOT
{
  "policies": ["superadmin"],
  "password": "changeme"
}
EOT
}

# Create and assign user in the IT namespace with the correct password
resource "vault_generic_endpoint" "simon_IT" {
  depends_on = [vault_auth_backend.userpass_IT]
  namespace  = vault_namespace.IT.path
  path       = "auth/userpass/users/simon"
  ignore_absent_fields = true
  data_json  = <<EOT
{
  "policies": ["namespace-admins"],
  "password": "changeme"
}
EOT
}

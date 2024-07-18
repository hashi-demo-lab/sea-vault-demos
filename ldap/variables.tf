variable "vault_address" {
  type        = string
  description = "vault address"
}

variable "ldap_roles" {
  description = "An object containing the role name and ldap groups to join."
  type = list(object({
    role_name   = string
    group_names = list(string)
  }))
  default = [
    {
      role_name   = "vault_ldap_dynamic_demo_role"
      group_names = ["dev"]
    }
  ]
}
variable "tfc_organization" {
  type        = string
  description = "(Required) The name of the TFC organization"
  nullable    = false
}

variable "tfc_project" {
  type        = string
  description = "(Required) The name of the TFC Project that the workspace is located within"
  nullable    = false
}

variable "vault_path" {
  type        = string
  description = "Vault path used for mount path of secrets engine and Vault policy"
  nullable    = false
}

variable "vault_address" {
  type        = string
  description = "vault address"
}

variable "region" {
  type        = string
  description = "aws region"
}

variable "doormat_user_arn" {
  type        = string
  description = "arn of doormat user"
}
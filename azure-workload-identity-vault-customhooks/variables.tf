## Variables file

/* variable "namespace" {
  description = "(Optional) - Namespace that will be used for the configuration"
  type        = string
  default     = null
} */

variable "tfc_organization" {
  type        = string
  description = "(Required) The name of the TFC organization"
  default     = null
}

variable "tfc_project" {
  type        = string
  description = "(Required) The name of the TFC Project that the workspace is located within"
  default     = null
}

variable "tfc_workspace" {
  type        = string
  description = "(Required) The name of the TFC workspace"
  default     = null
}

variable "VAULT_PATH" {
  type        = string
  description = "Vault path used for mount path of secrets engine and Vault policy"
  nullable    = false
}

variable "vault_address" {
  type        = string
  description = "vault address"
  default     = "http://localhost:8200"
}
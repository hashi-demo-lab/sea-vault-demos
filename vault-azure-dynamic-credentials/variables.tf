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

variable "vault_address" {
  type        = string
  description = "vault address"
}
variable "VAULT_PATH" {
  type        = string
  description = "Vault path used for mount path of secrets engine and Vault policy"
  nullable    = false
}

variable "tenant_id" {
  type        = string
  sensitive   = true
  description = "tenant_id - set using ENV TF_VAR_"
}

variable "subscription_id" {
  type        = string
  sensitive   = true
  description = "subscription_id - set using ENV TF_VAR_"
}

variable "client_id" {
  type        = string
  sensitive   = true
  description = "client_id - set using ENV TF_VAR_"
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "client_secret - set using ENV TF_VAR_"
}

variable "ttl" {
  type        = string
  description = "default ttl for azure secrets"
  default     = "15m"
}

variable "max_ttl" {
  type        = string
  description = "max ttl for azure secrets"
  default     = "60m"
}
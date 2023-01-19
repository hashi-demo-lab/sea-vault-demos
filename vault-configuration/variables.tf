variable "tfc_organization" {
  type        = string
  description = "(Required) The name of the TFC organization"
}

variable "tfc_workspace" {
  type        = string
  description = "(Required) The name of the TFC workspace"
}

variable "tfc_project" {
  type = string 
  description = "(Required) The name of the TFC Project that the workspace is located within"
  
}

variable "namespace" {
  type        = string
  description = "(Required) The name of the HCP Vault namespace"
}

variable "kv_secrets_path" {
  type    = string
  description = "(Required) KV Version 2 secret engine mount path"
}

variable "VAULT_SECRET_KEY" {
  type = string
  default = "pipeline_secrets"
}
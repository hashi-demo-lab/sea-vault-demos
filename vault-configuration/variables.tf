variable "tfc_organization" {
  type        = string
  description = "(Required) The name of the TFC organization"
  nullable = false
}

variable "tfc_workspace" {
  type        = string
  description = "(Required) The name of the TFC workspace"
  nullable = false
}

variable "tfc_project" {
  type        = string 
  description = "(Required) The name of the TFC Project that the workspace is located within"
  nullable = false
}

variable "kv_secrets_mount" {
  type        = string
  description = "KV Version 2 secret engine mount path"
  nullable = false
}

variable "kv_secrets_key" {
  type        = string
  description = "Name of the key inside a K/V secret engine"
  nullable = false
}
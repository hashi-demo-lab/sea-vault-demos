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
variable "tfc_workspace" {
  type        = string
  description = "(Required) The name of the TFC workspace"
  nullable    = false
}

variable "kv_secrets_mount" {
  type        = string
  description = "KV Version 2 secret engine mount path"
  nullable    = false
}

variable "kv_secrets_key" {
  type        = string
  description = "Name of the key inside a K/V secret engine"
  nullable    = false
}

variable "role_arns" {
  type        = string
  description = "Amazon Resource Name of the role in AWS IAM "
  nullable    = false
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

variable "region" {
  type        = string
  description = "aws region"
}

variable "doormat_user_arn" {
  type        = string
  description = "arn of doormat user"
  default     = "arn:aws:sts::258850230659:assumed-role/aws_aaron.evans_test-developer/aaron.evans@hashicorp.com"
}

variable "mysql_username" {
  type        = string
  description = "service account used for Vault to connect to the mysql container"
}

variable "mysql_password" {
  type        = string
  description = "password used for Vault to connect to the mysql container"
}

variable "mysql_application_username" {
  type        = string
  description = "This is static account used by an application (this could be an existing account)"
}

variable "app_prefix" {
  type = string
  description = "prefix for resource naming uniqueness"
}

variable "mysql_database_name" {
  type        = string
  description = "Name of the database within Vault configuration"
}
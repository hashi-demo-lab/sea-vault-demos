
variable "vault_address" {
  type        = string
  description = "vault address"
  default     = "http://localhost:8200"
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

variable "mysql_database_name" {
  type        = string
  description = "Name of the database within Vault configuration"
}
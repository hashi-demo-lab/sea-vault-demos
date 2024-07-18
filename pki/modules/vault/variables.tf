variable "vault_address" {
  type        = string
  description = "vault address"
}

variable "kubernetes_api" {
  type        = string
  description = "kubernetes control plane"
}

variable "kubernetes_ca_cert" {
  type        = string
  description = "kubernetes cluster certificate"
}

variable "token_reviewer_jwt" {
  type        = string
  description = "json web token"
}

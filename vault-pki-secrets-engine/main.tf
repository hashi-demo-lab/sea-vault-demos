module "vault-pki-starter" {

  source = "./modules/vault"

  vault_address      = var.vault_address
  kubernetes_api     = var.kubernetes_api
  kubernetes_ca_cert = var.kubernetes_ca_cert
  token_reviewer_jwt = var.token_reviewer_jwt
}
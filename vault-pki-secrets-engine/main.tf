provider "vault" {
  address = var.vault_address
}

resource "vault_mount" "pki" {
  path                      = "demo-pki"
  type                      = "pki"
  description               = "This is an example PKI secret engine mount"

  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_pki_secret_backend_root_cert" "this" {
  depends_on            = [vault_mount.pki]
  backend               = vault_mount.pki.path
  type                  = "internal"
  common_name           = "Root CA"
  ttl                   = "315360000"
  format                = "pem"
  private_key_format    = "der"
  key_type              = "rsa"
  key_bits              = 4096
  exclude_cn_from_sans  = true
  ou                    = "My OU"
  organization          = "My organization"
}

resource "vault_pki_secret_backend_config_urls" "this" {
  backend = vault_mount.pki.path
  issuing_certificates = [
    "http://127.0.0.1:8200/v1/pki/ca",
  ]
  crl_distribution_points = [ 
    "http://127.0.0.1:8200/v1/pki/ca",
  ]
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "my_role"
  ttl              = 3600
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["example.com", "my.domain"]
  allow_subdomains = true
}

resource "vault_mount" "this" {
  path                  = "demo-pki"
  type                  = "pki"
  description           = "This is an example PKI secret engine mount"
  max_lease_ttl_seconds = 31536000
}

resource "vault_pki_secret_backend_root_cert" "this" {
  depends_on   = [vault_mount.this]
  backend      = vault_mount.this.path
  type         = "internal"
  common_name  = "Vault Demo as a Root CA"
  ttl          = "315360000"
  organization = "hashi-demo-lab"
  ou           = "Solutions Engineering and Architecture"

}

resource "vault_pki_secret_backend_config_urls" "this" {
  backend = vault_mount.this.path
  issuing_certificates = [
    "http://127.0.0.1:8200/v1/pki/ca",
  ]
  crl_distribution_points = [
    "http://127.0.0.1:8200/v1/pki/crl",
  ]
}

resource "vault_pki_secret_backend_role" "this" {
  backend          = vault_mount.this.path
  name             = "my_role"
  allowed_domains  = ["example.com", "hashibank.com"]
  allow_subdomains = true
  max_ttl          = 180
  organization     = ["hashi-demo-lab"]
  ou               = ["Solutions Engineering and Architecture"]
}
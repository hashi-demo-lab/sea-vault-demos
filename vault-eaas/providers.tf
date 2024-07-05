terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4"
    }
  }
}

variable "vault_address" {
  type        = string
  description = "vault address"
  default = "https://vault-dc1.hashibank.com:443"
}

provider "vault" {
  address = var.vault_address
}

resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  description               = "DataKey creation and encryption as a service"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "key" {
  backend = vault_mount.transit.path
  name    = "my_key"
}

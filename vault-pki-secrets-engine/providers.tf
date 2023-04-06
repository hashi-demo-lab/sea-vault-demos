terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~>3.0"
    }
  }
}

provider "vault" {
  address = var.vault_address
}
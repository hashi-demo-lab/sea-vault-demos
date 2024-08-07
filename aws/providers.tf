terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "vault" {
  address = var.vault_address
}
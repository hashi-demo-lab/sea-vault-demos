terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.18.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.50.0"
    }
  }
}
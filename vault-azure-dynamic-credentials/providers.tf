terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.18.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.64.0"
    }
  }
}
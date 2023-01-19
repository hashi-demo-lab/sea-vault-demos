terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.50.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
  
  cloud {
    hostname     = "app.terraform.io"
    organization = "Aaron-HashiCorp-Demo-Org"
    workspaces {
      tags = [
        "aws","infra"
      ]
    }
  }
}
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
    organization = "hashi-demos-apj"
    
    workspaces {
      name = "aws-infra"
    }
  }
}
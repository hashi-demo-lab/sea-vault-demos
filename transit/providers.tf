terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

provider "vault" {
  address = var.vault_address
}

provider "aws" {
  region = "ap-southeast-2"
}

variable "vault_address" {
  type        = string
  description = "vault address"
  default = "https://vault-dc1.hashibank.com:443"
}

resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  description               = "DataKey creation and encryption as a service"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "aes256-gcm96" {
  backend = vault_mount.transit.path
  name    = "aes256-gcm96"
  type = "aes256-gcm96"
  deletion_allowed = true
}

resource "vault_transit_secret_backend_key" "aes256-gcm96-convergent_encryption" {
  backend = vault_mount.transit.path
  name    = "aes256-gcm96-convergent_encryption"
  type = "aes256-gcm96"
  deletion_allowed = true
  convergent_encryption = true
  derived = true
}


resource "vault_transit_secret_backend_key" "chacha20-poly1305" {
  backend = vault_mount.transit.path
  name    = "chacha20-poly1305"
  type = "chacha20-poly1305"
  deletion_allowed = true
}

resource "vault_transit_secret_backend_key" "rsa-4096" {
  backend = vault_mount.transit.path
  name    = "rsa-4096"
  type = "rsa-4096"
  deletion_allowed = true
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket-ae"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  force_destroy = true
  versioning = {
    enabled = true
  }
}
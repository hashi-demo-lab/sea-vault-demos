# Create a KV secrets engine
resource "vault_mount" "main" {
  path        = var.kv_secrets_mount
  type        = "kv"
  options     = { version = "2" }
  description = "Key/Value mount for Workload Identity demo"
}

resource "vault_kv_secret_v2" "empty-secret" {
  mount = vault_mount.main.path
  name  = "empty_secret"
  data_json = jsonencode(
    {
    }
  )
}

# Create a secret in the KV engine
resource "vault_kv_secret_v2" "team_sea_secrets" {
  mount = vault_mount.main.path
  name  = var.kv_team_secrets_name
  data_json = jsonencode(
    {
      team          = "Solution Engineers and Architects",
      location      = "Australia and New Zealand"
      football_team = "Sydney Swans"
    }
  )
  custom_metadata {
    max_versions = 5
    data = {
      demo    = "true",
      account = "Services Australia"
    }
  }
}

resource "vault_kv_secret_v2" "simons_secrets" {
  mount = vault_mount.main.path
  name  = var.kv_simons_secrets_name
  data_json = jsonencode(
    {
      role          = "Sr Solutions Architecture Specialist",
      location      = "Sydney"
      football_team = "Cronulla Sharks"
    }
  )
}

resource "vault_kv_secret_v2" "aarons_secrets" {
  mount = vault_mount.main.path
  name  = var.kv_aarons_secrets_name
  data_json = jsonencode(
    {
      role          = "Solutions Engineer",
      location      = "Kiama"
      football_team = "Canterbury-Bankstown Bulldogs"
    }
  )
}
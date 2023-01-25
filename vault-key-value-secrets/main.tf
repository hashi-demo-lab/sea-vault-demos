provider "vault" {
  address = var.vault_address
}

resource "vault_namespace" "finance" {
  path = "finance"
}

resource "vault_namespace" "engineering" {
  path = "engineering"
}

resource "vault_namespace" "education" {
  path = "education"
}

# Create a childnamespace, 'training' under 'education'
resource "vault_namespace" "training" {
  namespace = vault_namespace.education.path
  path = "training"
}

# Create a childnamespace, 'vault_cloud' and 'boundary' under 'education/training'
resource "vault_namespace" "vault_cloud" {
  namespace = vault_namespace.training.path_fq
  path = "vault_cloud"
}

# Create 'education/training/boundary' namespace
resource "vault_namespace" "boundary" {
  namespace = vault_namespace.training.path_fq
  path = "boundary"
}
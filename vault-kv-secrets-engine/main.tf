provider "vault" {
  address = var.vault_address
  skip_tls_verify = true
}

resource "vault_namespace" "IT" {
  path = "IT"
}

resource "vault_namespace" "IT_Prod" {
  namespace = vault_namespace.IT.path
  path      = "IT_Prod"
}
resource "vault_namespace" "IT_Dev" {
  namespace = vault_namespace.IT.path
  path      = "IT_Dev"
}

resource "vault_namespace" "Payments" {
  path = "payments"
}

resource "vault_namespace" "Payments_TeamA" {
  namespace = vault_namespace.Payments.path
  path      = "Payments_TeamA"
}
resource "vault_namespace" "Payments_TeamB" {
  namespace = vault_namespace.Payments.path
  path      = "Payments_TeamB"
}

resource "vault_namespace" "Payments_TeamA_Prod" {
  namespace = vault_namespace.Payments_TeamA.path_fq
  path      = "Payments_TeamA_Prod"
}
resource "vault_namespace" "Payments_TeamB_Prod" {
  namespace = vault_namespace.Payments_TeamB.path_fq
  path      = "Payments_TeamB_Prod"
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
  path      = "training"
}

# Create a childnamespace, 'vault_cloud' and 'boundary' under 'education/training'
resource "vault_namespace" "vault_cloud" {
  namespace = vault_namespace.training.path_fq
  path      = "vault_cloud"
}

# Create 'education/training/boundary' namespace
resource "vault_namespace" "boundary" {
  namespace = vault_namespace.training.path_fq
  path      = "boundary"
}
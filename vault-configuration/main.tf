provider "vault" {
  address = var.vault_address
}

provider "aws" {
  region = var.region
}

# Create a KV secrets engine
resource "vault_mount" "main" {
  path        = var.kv_secrets_mount
  type        = "kv"
  options     = { version = "2" }
  description = "KV mount for TFC OIDC demo"
}

# Create a secret in the KV engine
resource "vault_kv_secret_v2" "main" {
  mount = vault_mount.main.path
  name  = var.kv_secrets_key
  data_json = jsonencode(
    {
      team     = "solution engineers and architects",
      location = "sydney"
    }
  )
}

# Enable AWS Secrets Engine
resource "vault_aws_secret_backend" "main" {
  description = "Demo of the AWS secrets engine"
  path = var.VAULT_PATH
}

resource "aws_iam_role" "role" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole",
                "sts:SetSourceIdentity"],
      "Principal": {
        "AWS": "${var.doormat_user_arn}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}


# Configure AWS Secrets Engine with Assumed Role
resource "vault_aws_secret_backend_role" "main" {
  backend         = vault_aws_secret_backend.main.path
  credential_type = "assumed_role"
  name            = "vault-demo-assumed-role"
  role_arns       = [aws_iam_role.role.arn]
}

# Create the JWT auth method to use GitHub
resource "vault_jwt_auth_backend" "main" {
  description        = "JWT Backend for TFC OIDC"
  path               = "jwt"
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

# Create the JWT role tied to workspaceOne
resource "vault_jwt_auth_backend_role" "main" {
  backend           = vault_jwt_auth_backend.main.path
  role_name         = "vault-demo-assumed-role"
  token_policies    = [vault_policy.main.name]
  token_max_ttl     = "100"
  bound_audiences   = ["vault.testing"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization}:project:${var.tfc_project}:workspace:${var.tfc_workspace}:run_phase:*"
  }
  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
}
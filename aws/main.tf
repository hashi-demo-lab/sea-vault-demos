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
        "ec2:*",
        "s3:*",
        "route53:*",
        "ssm:*",
        "iam:CreateRole",
        "iam:GetRole",
        "iam:GetInstanceProfile",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole",
        "iam:AttachRolePolicy",
        "iam:PassRole",
        "iam:AddRoleToInstanceProfile",
        "iam:CreateInstanceProfile",
        "iam:DeleteRole",
        "iam:DetachRolePolicy",
        "iam:DeleteInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile"
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

# Enable AWS Secrets Engine
resource "vault_aws_secret_backend" "main" {
  description = "Demo of the AWS secrets engine"
  path        = var.vault_path
}

# Configure AWS Secrets Engine with Assumed Role
resource "vault_aws_secret_backend_role" "main" {
  backend         = vault_aws_secret_backend.main.path
  credential_type = "assumed_role"
  name            = "vault-demo-assumed-role"
  role_arns       = [aws_iam_role.role.arn]
}

# Enable the JWT authentication method for TFC Workload Identity
resource "vault_jwt_auth_backend" "main" {
  description        = "AWS - JWT Backend for TFC OIDC"
  path               = "aws_jwt"
  type               = "jwt"
  oidc_discovery_url = "https://app.terraform.io"
  bound_issuer       = "https://app.terraform.io"
}

resource "vault_jwt_auth_backend_role" "main" {
  backend        = vault_jwt_auth_backend.main.path
  role_name      = "vault-demo-assumed-role"
  token_policies = [vault_policy.main.name]

  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization}:project:${var.tfc_project}:workspace:*:run_phase:*"
  }

  user_claim    = "terraform_full_workspace"
  role_type     = "jwt"
  token_max_ttl = "900"
}

resource "vault_jwt_auth_backend_role" "team-a" {
  backend        = vault_jwt_auth_backend.main.path
  role_name      = "team-a-assumed-role"
  token_policies = [vault_policy.main.name]

  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization}:project:Team A:workspace:*:run_phase:*"
  }

  user_claim    = "terraform_full_workspace"
  role_type     = "jwt"
  token_max_ttl = "900"
}

resource "vault_jwt_auth_backend_role" "team-b" {
  backend        = vault_jwt_auth_backend.main.path
  role_name      = "team-b-assumed-role"
  token_policies = [vault_policy.main.name]

  bound_audiences   = ["vault.workload.identity"]
  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization}:project:Team B:workspace:*:run_phase:*"
  }

  user_claim    = "terraform_full_workspace"
  role_type     = "jwt"
  token_max_ttl = "900"
}
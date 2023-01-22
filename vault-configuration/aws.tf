# Enable AWS Secrets Engine
resource "vault_aws_secret_backend" "main" {
  description = "Demo of the AWS secrets engine"
  path        = var.VAULT_PATH
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
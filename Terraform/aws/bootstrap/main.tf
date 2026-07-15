data "aws_caller_identity" "current" {}

#
# Terraform state bucket
#

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# GitHub OpenID Connect provider
#

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

#
# Trust policy for GitHub Actions
#

data "aws_iam_policy_document" "github_trust" {
  statement {
    sid    = "GitHubActionsAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:${var.github_owner}/${var.github_repository}:ref:refs/heads/${var.github_branch}"
      ]
    }
  }
}

resource "aws_iam_role" "github_terraform" {
  name                 = "mypawsbnb-github-terraform"
  description          = "Role used by GitHub Actions to deploy mypawsbnb AWS infrastructure"
  assume_role_policy   = data.aws_iam_policy_document.github_trust.json
  max_session_duration = 3600
}

#
# Terraform state permissions
#

data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid    = "ListTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn
    ]
  }

  statement {
    sid    = "ManageTerraformStateFiles"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "terraform_state" {
  name        = "mypawsbnb-terraform-state-access"
  description = "Allows GitHub Actions to access the mypawsbnb Terraform state"
  policy      = data.aws_iam_policy_document.terraform_state.json
}

resource "aws_iam_role_policy_attachment" "terraform_state" {
  role       = aws_iam_role.github_terraform.name
  policy_arn = aws_iam_policy.terraform_state.arn
}

#
# Starter deployment permissions
#
# These are broader than the final least-privilege policy.
# We will tighten them after the RDS configuration is working.
#

resource "aws_iam_role_policy_attachment" "rds_access" {
  role       = aws_iam_role.github_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.github_terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}
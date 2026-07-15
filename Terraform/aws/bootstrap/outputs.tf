output "aws_account_id" {
  description = "AWS account where the bootstrap resources were created."
  value       = data.aws_caller_identity.current.account_id
}

output "terraform_state_bucket" {
  description = "S3 bucket used for AWS Terraform state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "github_actions_role_name" {
  description = "IAM role used by GitHub Actions."
  value       = aws_iam_role.github_terraform.name
}

output "github_actions_role_arn" {
  description = "IAM role ARN that the GitHub workflow will assume."
  value       = aws_iam_role.github_terraform.arn
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC identity provider ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}
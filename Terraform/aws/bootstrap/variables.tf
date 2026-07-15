variable "aws_region" {
  description = "AWS Region used for the deployment."
  type        = string
  default     = "us-east-2"
}

variable "github_owner" {
  description = "GitHub organization or account that owns the repository."
  type        = string
  default     = "oracleminded"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the AWS role."
  type        = string
  default     = "mypawsbnb"
}

variable "github_branch" {
  description = "GitHub branch allowed to deploy to AWS."
  type        = string
  default     = "main"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket used for AWS Terraform state."
  type        = string
  default     = "mypawsbnb-terraform-state-061446588118-us-east-2"
}
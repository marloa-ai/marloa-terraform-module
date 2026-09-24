variable "project" {
  description = "Project prefix used in resource names, secret and parameter paths (e.g. marloa)."
  type        = string
}

variable "github_org" {
  description = "GitHub organization owning the repos."
  type        = string
}

variable "infra_repo" {
  description = "Infra (Terraform) repository name."
  type        = string
}

variable "app_repo" {
  description = "Application monorepo name."
  type        = string
}

variable "environment" {
  description = "Deployment environment hosted in this account (staging or prod). Also the GitHub Environment name."
  type        = string
}

variable "state_bucket_arn" {
  description = "Terraform state bucket the plan role may read and lock."
  type        = string
}

variable "ecr_repository_arns" {
  description = "ECR repositories the app repo may push to. Empty = no push role in this account."
  type        = list(string)
  default     = []
}

variable "state_kms_key_arn" {
  description = "KMS key encrypting the state bucket."
  type        = string
}

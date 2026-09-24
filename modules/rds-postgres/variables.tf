variable "name" {
  description = "Instance identifier, e.g. marloa-staging-public."
  type        = string
}

variable "secret_name" {
  description = "Secrets Manager name, e.g. marloa/staging/database/public."
  type        = string
}

variable "vpc_id" {
  description = "VPC of the instance."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnets for the DB subnet group."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to reach 5432."
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "KMS key for storage, Performance Insights and the secret."
  type        = string
}

variable "db_name" {
  description = "Initial database name."
  type        = string
}

variable "username" {
  description = "Master username."
  type        = string
}

variable "password_version" {
  description = "Increment to generate and set a new master password."
  type        = number
  default     = 1

  validation {
    condition     = var.password_version >= 1
    error_message = "password_version starts at 1 and only increases."
  }
}

variable "engine_version" {
  description = "PostgreSQL version (major pins the family)."
  type        = string
  default     = "17"
}

variable "instance_class" {
  description = "Instance class."
  type        = string
  default     = "db.t4g.small"
}

variable "allocated_storage" {
  description = "Initial storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Storage autoscaling ceiling in GiB."
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Run Multi-AZ."
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Backup / PITR retention in days."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Protect from deletion."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on deletion."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply modifications immediately instead of in the maintenance window."
  type        = bool
  default     = false
}

variable "secret_recovery_window_days" {
  description = "Days a deleted secret can be restored (0 = force delete)."
  type        = number
  default     = 7
}

variable "log_min_duration_ms" {
  description = "Log statements slower than this many milliseconds (-1 disables)."
  type        = number
  default     = 1000
}

variable "log_retention_days" {
  description = "CloudWatch retention for exported PostgreSQL logs."
  type        = number
  default     = 30
}

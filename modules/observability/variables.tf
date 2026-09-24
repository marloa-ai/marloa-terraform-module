variable "name" {
  description = "Name prefix for alarms and the topic."
  type        = string
}

variable "alarm_emails" {
  description = "Email addresses subscribed to the topic."
  type        = list(string)
  default     = []
}

variable "db_instance_id" {
  description = "RDS instance to alarm on."
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for API alarms."
  type        = string
}

variable "api" {
  description = "API service details; null until the service exists."
  type = object({
    cluster_name            = string
    service_name            = string
    target_group_arn_suffix = string
  })
  default = null
}

variable "kms_key_arn" {
  description = "KMS key encrypting the alarm topic."
  type        = string
}

variable "name" {
  description = "Name prefix for network resources."
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block."
  type        = string
}

variable "azs" {
  description = "Availability zones."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per AZ."
  type        = list(string)
}

variable "enable_interface_endpoints" {
  description = "Create interface endpoints so ECR pulls, secrets and logs skip NAT. Costs roughly USD 7/month per endpoint per AZ."
  type        = bool
  default     = false
}

variable "interface_endpoints" {
  description = "Interface endpoint service suffixes to create."
  type        = list(string)
  default     = ["ecr.api", "ecr.dkr", "secretsmanager", "logs", "ssm"]
}

variable "flow_logs_traffic_type" {
  description = "VPC flow log capture: ALL, ACCEPT, REJECT, or null to disable."
  type        = string
  default     = "ALL"

  validation {
    condition     = var.flow_logs_traffic_type == null || contains(["ALL", "ACCEPT", "REJECT"], coalesce(var.flow_logs_traffic_type, "ALL"))
    error_message = "flow_logs_traffic_type must be ALL, ACCEPT, REJECT or null."
  }
}

variable "flow_logs_retention_days" {
  description = "CloudWatch retention for VPC flow logs."
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS key encrypting the flow log group."
  type        = string
}

variable "name" {
  description = "Name prefix for the ALB and its security group."
  type        = string
}

variable "vpc_id" {
  description = "VPC to place the ALB in."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR the ALB may send traffic to."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnets for the internal ALB."
  type        = list(string)
}

variable "idle_timeout" {
  description = "Seconds. Must exceed the 45 s outbound agent-ready wait."
  type        = number
  default     = 120
}

variable "deletion_protection" {
  description = "Protect the ALB from deletion."
  type        = bool
  default     = false
}

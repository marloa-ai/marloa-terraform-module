variable "name" {
  description = "Service name, e.g. marloa-staging-api. Also the task family."
  type        = string
}

variable "cluster_arn" {
  description = "ECS cluster ARN."
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name."
  type        = string
}

variable "vpc_id" {
  description = "VPC of the service."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnets for the tasks."
  type        = list(string)
}

variable "image" {
  description = "Initial image URI. Later deploys replace it from CI."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "Task CPU units (1024 = 1 vCPU)."
  type        = number
  default     = 512

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096, 8192, 16384], var.cpu)
    error_message = "cpu must be a valid Fargate CPU size."
  }
}

variable "memory" {
  description = "Task memory in MiB."
  type        = number
  default     = 1024
}

variable "environment" {
  description = "Plain environment variables."
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Env var name => Secrets Manager valueFrom (ARN or ARN:json-key::)."
  type        = map(string)
  default     = {}
}

variable "secret_arns" {
  description = "Secret ARNs the execution role may read."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "Key for log group encryption and secret decryption."
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB security group allowed to reach the tasks."
  type        = string
  default     = null
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for request-count scaling."
  type        = string
  default     = null
}

variable "listener_arn" {
  description = "ALB listener to attach the routing rule to. Null runs the service without a load balancer."
  type        = string
  default     = null
}

variable "listener_rule_priority" {
  description = "Priority of the listener rule (unique per listener)."
  type        = number
  default     = null
}

variable "path_patterns" {
  description = "Paths routed to this service."
  type        = list(string)
  default     = ["/*"]
}

variable "health_check_path" {
  description = "Target group health check path."
  type        = string
  default     = "/health"
}

variable "desired_count" {
  description = "Initial task count; autoscaling owns it afterwards."
  type        = number
  default     = 1
}

variable "min_capacity" {
  description = "Autoscaling minimum task count."
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Autoscaling maximum task count."
  type        = number
  default     = 2
}

variable "cpu_target_percent" {
  description = "Average CPU to target when scaling."
  type        = number
  default     = 60
}

variable "requests_per_target" {
  description = "ALB requests per target per minute before scaling out."
  type        = number
  default     = 1000
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 30
}

variable "stop_timeout" {
  description = "Seconds to drain in-flight requests (outbound call setup waits up to 45 s)."
  type        = number
  default     = 60

  validation {
    condition     = var.stop_timeout >= 2 && var.stop_timeout <= 120
    error_message = "Fargate stopTimeout must be 2-120 seconds."
  }
}

variable "egress_rules" {
  description = "Outbound TCP rules for the tasks (port, IPv4 CIDR, description)."
  type = list(object({
    port        = number
    cidr        = string
    description = string
  }))
  default = [
    { port = 443, cidr = "0.0.0.0/0", description = "HTTPS to AWS APIs and external services" },
  ]

  validation {
    condition     = alltrue([for r in var.egress_rules : can(cidrhost(r.cidr, 0)) && r.port > 0 && r.port < 65536])
    error_message = "Each egress rule needs a valid port and IPv4 CIDR."
  }
}

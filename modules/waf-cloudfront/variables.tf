variable "name" {
  description = "Web ACL name."
  type        = string
}

variable "rate_limit_per_5min" {
  description = "Requests per 5 minutes per client IP before blocking."
  type        = number
  default     = 2000
}

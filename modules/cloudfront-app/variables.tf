variable "name" {
  description = "Name prefix for edge resources."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique name of the dashboard bucket."
  type        = string
}

variable "alb_arn" {
  description = "Internal ALB exposed through the VPC origin."
  type        = string
}

variable "alb_dns_name" {
  description = "Internal DNS name of that ALB."
  type        = string
}

variable "api_path_patterns" {
  description = "Paths forwarded to the API instead of S3."
  type        = list(string)
  default     = ["/api/*", "/health"]
}

variable "origin_read_timeout" {
  description = "Seconds CloudFront waits for the API. 60 is the default quota and covers the 45 s outbound call wait."
  type        = number
  default     = 60

  validation {
    condition     = var.origin_read_timeout >= 1 && var.origin_read_timeout <= 180
    error_message = "origin_read_timeout must be 1-180 seconds (above 60 needs a quota increase)."
  }
}

variable "web_acl_arn" {
  description = "CloudFront-scoped WAF web ACL ARN."
  type        = string
}

variable "aliases" {
  description = "Custom hostnames for the distribution."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "us-east-1 certificate covering `aliases`. Required when aliases are set."
  type        = string
  default     = null
}

variable "price_class" {
  description = "CloudFront price class (PriceClass_200 includes India)."
  type        = string
  default     = "PriceClass_200"

  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "Invalid CloudFront price class."
  }
}

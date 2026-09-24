variable "name" {
  description = "Key alias suffix, e.g. marloa-staging."
  type        = string
}

variable "deletion_window_in_days" {
  description = "Waiting period before a scheduled key deletion completes."
  type        = number
  default     = 30
}

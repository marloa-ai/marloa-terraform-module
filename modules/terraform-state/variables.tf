variable "bucket_name" {
  description = "Globally unique name for the state bucket."
  type        = string
}

variable "kms_alias" {
  description = "Alias (without alias/) for the state encryption key; referenced by backend blocks."
  type        = string
}

variable "repositories" {
  description = "Repository names to create, e.g. [\"marloa/api\"]."
  type        = list(string)
}

variable "pull_account_ids" {
  description = "Other AWS account IDs allowed to pull images."
  type        = list(string)
  default     = []
}

variable "keep_tagged_images" {
  description = "Number of tagged images to retain per repository."
  type        = number
  default     = 100
}

variable "role_name" {
  description = "IAM Role Name"
}

variable "trusted_resource" {
  description = "Principal trust policy resource"
}

variable "policy-actions" {
  type = list(string)
}

variable "resources" {
  type = list(string)
}

variable "managed_policy_arns" {
  type = list(string)
}

variable "output_path" {}

variable "source_file" {}

variable "function_name" {}

variable "handler" {}

variable "runtime" {}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {}
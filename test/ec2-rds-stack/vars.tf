variable "AWS_REGION" {
  description = "AWS Region"
  default = "us-east-1"
}

variable "MARIADB_PASSWORD" {}

variable "PATH_TO_PUBLIC_KEY" {
  default = "my_aws_key.pub"
}
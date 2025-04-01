variable "PATH_TO_PUBLIC_KEY" {
  default = "my_aws_key.pub"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "my_aws_key"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-0ac019f4fcb7cb7e6"
    us-east-2 = "ami-02e680c4540db351e"
  }
}

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "INSTANCE_COUNT" {
  default = 2
}

variable "NAME" {
  default = "my-test"
}

variable "ALB_PORT" {
  type    = number
  default = 80
}

variable "TG_PORT" {
  type    = number
  default = 80
}

variable "ALB_PROTOCOL" {
  default = "HTTP"
}

variable "TG_PROTOCOL" {
  default = "HTTP"
}
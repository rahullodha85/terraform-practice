variable "AWS_REGION" {
  description = "AWS Region"
  default = "us-east-1"
}

variable "AMIS" {
  type = "map"
  default = {
    us-east-1 = "ami-009d6802948d06e52"
  }
}

variable "INSTANCE_SIZE" {
  description = "aws instance size"
  default = "t2.micro"
}
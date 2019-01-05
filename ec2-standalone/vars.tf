variable "AWS_REGION" {
  description = "AWS Region"
}

variable "AMIS" {
  type = "map"
  default = {
    us-east-1 = "ami-0ac019f4fcb7cb7e6"
    us-east-2 = "ami-02e680c4540db351e"
  }
}

variable "INSTANCE_SIZE" {
  description = "aws instance size"
  default = "t2.micro"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "my_aws_key.pub"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "my_aws_key"
}

variable "INSTANCE_USER" {
  default = "ubuntu"
}

variable "SUBNET_ID" {}

variable "VPC_SECURITY_GRPS" {
  type = "list"
}

variable "CLOUD_INIT_TEMPLATE" {}

variable "SECURITY_GRPS" {
  type = "list"
}

variable "EBS_VOLUME_ID" {}
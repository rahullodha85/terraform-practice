variable "AWS_REGION" {
  description = "AWS Region"
}

variable "AMIS" {
  type = map(string)

  default = {
    us-east-1 = "ami-0ac019f4fcb7cb7e6"
    us-east-2 = "ami-02e680c4540db351e"
  }
}

variable "INSTANCE_SIZE" {
  description = "aws instance size"
  default     = "t2.micro"
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

variable "SUBNET_ID" {
  type = list(string)
}

variable "VPC_SECURITY_GRPS" {
  type = list(string)
}

variable "USER_DATA" {
}

variable "KEY_NAME" {
}

variable "INSTANCE_COUNT" {
}

variable "AVAILABILITY_ZONE" {
  type = list(string)
}

variable "ASSOCIATE_PUBLIC_IP_ADDRESS" {
  default = "true"
}

variable "MY_AMI" {}

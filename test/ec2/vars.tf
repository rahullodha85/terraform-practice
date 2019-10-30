variable "AWS_REGION" {
  default = "us-east-1"
}

variable "COUNT" {
  default = 1
}

variable "MY_AMI" {
  default = "ami-0039a1a6250e023b8"
}

variable "AMIS" {
  type = map(string)

  default = {
    us-east-1 = "ami-0ac019f4fcb7cb7e6"
    us-east-2 = "ami-02e680c4540db351e"
  }
}
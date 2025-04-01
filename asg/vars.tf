variable "AMI_ID" {
  description = "AMI ID"
}

variable "INSTANCE_TYPE" {
  default = "t2.micro"
}

variable "SECURITY_GRPS" {
  type = list(string)
}

variable "MAX_SIZE" {
  default = "2"
}

variable "MIN_SIZE" {
  default = "1"
}

variable "VPC_ZONE_IDENTIFIER" {
  type = list(string)
}

variable "AWS_KEY" {
}

variable "FILE_NAME" {
}

variable "HEALTHCHK_TYPE" {
}

variable "USER_DATA" {
  type = string
}

variable "TARGET_GROUP_ARNS" {
  type = list(string)
}
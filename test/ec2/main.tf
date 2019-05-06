module "data-queries" {
  source = "../../data-queries"
  COUNT = "${var.COUNT}"
}

module "ec2-instance" {
  source = "../../ec2-standalone"
  VPC_SECURITY_GRPS = ["${module.sec-grp.id}"]
  KEY_NAME = "${module.key.key_name}"
  AWS_REGION = "${var.AWS_REGION}"
  EBS_VOLUME_ID = ""
  USER_DATA = ""
  COUNT = "${var.COUNT}"
  AVAILABILITY_ZONE = "${module.data-queries.availability-zones}"
  SUBNET_ID = "${module.data-queries.tf-vpc-subnet-public}"
}

module "key" {
  source = "./../../key"
}

provider "aws" {
  region = "${var.AWS_REGION}"
}

module "sec-grp" {
  source = "../../security-group"
  VPC_ID = "${module.data-queries.vpc-main}"
  SECURITY_GRP_DESCRIPTION = "test"
  SECURITY_GRP_NAME = "test"
}
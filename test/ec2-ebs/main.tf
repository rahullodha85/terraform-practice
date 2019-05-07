module "data-queries" {
  source = "../../data-queries"
  COUNT  = "${var.INSTANCE_COUNT}"
}

module "ec2-instance" {
  source            = "./../../ec2-standalone"
  VPC_SECURITY_GRPS = ["${module.security-grp.id}"]
  AWS_REGION        = "us-east-1"
  USER_DATA         = "${module.ebs.cloudinit-storage-template}"
  KEY_NAME          = "${module.key.key_name}"
  SUBNET_ID         = "${module.data-queries.tf-vpc-subnet-public}"
  INSTANCE_COUNT    = "${var.INSTANCE_COUNT}"
  AVAILABILITY_ZONE = "${module.data-queries.availability-zones}"
}

module "ebs" {
  source            = "./../../storage"
  AVAILABILITY_ZONE = "${module.data-queries.availability-zones}"
  INSTANCE_COUNT    = "${var.INSTANCE_COUNT}"
}

module "storage-attachment" {
  source          = "./../../storage-attachment"
  EBS_VOLUME_ID   = "${module.ebs.ebs-volume-id}"
  EC2_INSTANCE_ID = "${module.ec2-instance.id}"
  INSTANCE_COUNT  = "${var.INSTANCE_COUNT}"
}

module "key" {
  source = "./../../key"
}

module "security-grp" {
  source                   = "./../../security-group"
  VPC_ID                   = "${module.data-queries.vpc-main}"
  SECURITY_GRP_DESCRIPTION = "ec2-instance security group"
  SECURITY_GRP_NAME        = "ec2-security-grp"
}

module "ec2-egress" {
  source          = "./../../security-group-rule/cidr"
  FROM_PORT       = 0
  TYPE            = "egress"
  CIDR_BLOCKS     = ["0.0.0.0/0"]
  PROTOCOL        = -1
  SECURITY_GRP_ID = "${module.security-grp.id}"
  TO_PORT         = 0
}

module "ec2-ingress-ssh" {
  source          = "./../../security-group-rule/cidr"
  FROM_PORT       = 22
  SECURITY_GRP_ID = "${module.security-grp.id}"
  TYPE            = "ingress"
  TO_PORT         = 22
  CIDR_BLOCKS     = ["0.0.0.0/0"]
  PROTOCOL        = "tcp"
}

terraform {
  backend "s3" {
    bucket = "rogue-bucket"
    key    = "terraform/ec2-ebs"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "${var.AWS_REGION}"
}

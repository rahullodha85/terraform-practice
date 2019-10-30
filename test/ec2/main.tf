module "data-queries" {
  source = "../../data-queries"
  COUNT  = var.COUNT
}

module "ec2-instance" {
  source            = "../../ec2-standalone"
  VPC_SECURITY_GRPS = [module.sec-grp.id]
  KEY_NAME          = module.key.key_name
  AWS_REGION        = var.AWS_REGION
  USER_DATA         = ""
  INSTANCE_COUNT    = var.COUNT
  AVAILABILITY_ZONE = module.data-queries.availability-zones
  SUBNET_ID         = module.data-queries.tf-vpc-subnet-public
  MY_AMI            = var.MY_AMI
}

module "key" {
  source = "./../../key"
}

provider "aws" {
  region = var.AWS_REGION
}

module "sec-grp" {
  source                   = "../../security-group"
  VPC_ID                   = module.data-queries.vpc-main
  SECURITY_GRP_DESCRIPTION = "test"
  SECURITY_GRP_NAME        = "test"
}

module "ssh-rule" {
  source = "../../security-group-rule/cidr"
  CIDR_BLOCKS = ["0.0.0.0/0"]
  FROM_PORT = "22"
  PROTOCOL = "tcp"
  SECURITY_GRP_ID = module.sec-grp.id
  TO_PORT = "22"
  TYPE = "ingress"
}

terraform {
  backend "s3" {
    bucket = "rogue-bucket"
    key    = "terraform/ec2-test"
    region = "us-east-1"
  }
}


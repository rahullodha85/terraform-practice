module "auto_scaling" {
  source              = "./../../asg"
  AMI_ID              = var.AMIS[var.AWS_REGION]
  SECURITY_GRPS       = [module.ec2-security-grp.id]
  VPC_ZONE_IDENTIFIER = module.data-queries.tf-vpc-subnet-public
  AWS_KEY             = module.key.key_name
  FILE                = data.template_cloudinit_config.user-data.rendered
  HEALTHCHK_TYPE      = "EC2"
  LOAD_BALANCERS      = []
  MAX_SIZE            = var.INSTANCE_COUNT
}

module "data-queries" {
  source = "../../data-queries"
  COUNT  = var.INSTANCE_COUNT
}

module "key" {
  source             = "./../../key"
  PATH_TO_PUBLIC_KEY = var.PATH_TO_PUBLIC_KEY
}

module "ec2-security-grp" {
  source                   = "./../../security-group"
  SECURITY_GRP_DESCRIPTION = "ec2-instance security group"
  VPC_ID                   = module.data-queries.vpc-main
  SECURITY_GRP_NAME        = "ec2-instance-security-grp"
}

module "ec2-egress" {
  source          = "./../../security-group-rule/cidr"
  FROM_PORT       = 0
  TO_PORT         = 0
  CIDR_BLOCKS     = ["0.0.0.0/0"]
  TYPE            = "egress"
  PROTOCOL        = "-1"
  SECURITY_GRP_ID = module.ec2-security-grp.id
}

module "ec2-ingress-ssh" {
  source          = "./../../security-group-rule/cidr"
  TYPE            = "ingress"
  SECURITY_GRP_ID = module.ec2-security-grp.id
  CIDR_BLOCKS     = ["0.0.0.0/0"]
  PROTOCOL        = "tcp"
  FROM_PORT       = 22
  TO_PORT         = 22
}

module "ec2-ingress-web" {
  source          = "./../../security-group-rule/cidr"
  FROM_PORT       = 80
  SECURITY_GRP_ID = module.ec2-security-grp.id
  TYPE            = "ingress"
  TO_PORT         = 80
  PROTOCOL        = "tcp"
  CIDR_BLOCKS     = ["0.0.0.0/0"]
}

provider "aws" {
  region = var.AWS_REGION
}

terraform {
  backend "s3" {
    bucket = "rogue-bucket"
    key    = "terraform/asg"
    region = "us-east-1"
  }
}

variable "TEST" {
}
data "template_file" "shell-script" {
  template = file("${path.module}/script.sh")
  vars = {
    TEST = var.TEST
  }
}

data "template_cloudinit_config" "user-data" {

  part {
    filename     = data.template_file.shell-script.filename
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }
}


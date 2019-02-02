module "auto_scaling" {
  source = "./../../asg"
  AMI_ID = "${lookup(var.AMIS, var.AWS_REGION)}"
  SECURITY_GRPS = ["${module.ec2-security-grp.id}"]
  VPC_ZONE_IDENTIFIER = ["${module.vpc.subnet-public-1a-id}", "${module.vpc.subnet-public-1b-id}"]
  AWS_KEY = "${module.key.key_name}"
  FILE_NAME = "script.sh"
  HEALTHCHK_TYPE = "EC2"
  LOAD_BALANCERS = []
}

module "vpc" {
  source = "./../../vpc"
}

module "key" {
  source = "./../../key"
  PATH_TO_PUBLIC_KEY = "${var.PATH_TO_PUBLIC_KEY}"
}

module "ec2-security-grp" {
  source = "./../../security-group"
  SECURITY_GRP_DESCRIPTION = "ec2-instance security group"
  VPC_ID = "${module.vpc.vpc_id}"
  SECURITY_GRP_NAME = "ec2-instance-security-grp"
}

module "ec2-egress" {
  source = "./../../security-group-rule/cidr"
  FROM_PORT = 0
  TO_PORT = 0
  CIDR_BLOCKS = ["0.0.0.0/0"]
  TYPE = "egress"
  PROTOCOL = "-1"
  SECURITY_GRP_ID = "${module.ec2-security-grp.id}"
}

module "ec2-ingress-ssh" {
  source = "./../../security-group-rule/cidr"
  TYPE = "ingress"
  SECURITY_GRP_ID = "${module.ec2-security-grp.id}"
  CIDR_BLOCKS = ["0.0.0.0/0"]
  PROTOCOL = "tcp"
  FROM_PORT = 22
  TO_PORT = 22
}

module "ec2-ingress-web" {
  source = "./../../security-group-rule/cidr"
  FROM_PORT = 80
  SECURITY_GRP_ID = "${module.ec2-security-grp.id}"
  TYPE = "ingress"
  TO_PORT = 80
  PROTOCOL = "tcp"
  CIDR_BLOCKS = ["0.0.0.0/0"]
}
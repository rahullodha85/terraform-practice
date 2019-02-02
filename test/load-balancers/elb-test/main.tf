module "elb" {
  source = "./../../../load-balancers/elb"
  SECURITY_GRPS = ["${module.security_grp_elb.id}"]
  SUBNETS = ["${module.vpc.subnet-public-1a-id}", "${module.vpc.subnet-public-1b-id}"]
}

module "vpc" {
  source = "./../../../vpc"
}

module "key" {
  source = "./../../../key"
}

module "security_grp_ec2" {
  source = "./../../../security-group"
  SECURITY_GRP_NAME = "ec2-instance-security-grp"
  SECURITY_GRP_DESCRIPTION = "ec2-instance secutiry group"
  VPC_ID = "${module.vpc.vpc_id}"
}

module "security_grp_rule_ec2_egress" {
  source = "./../../../security-group-rule/source_security_grp"
  FROM_PORT = 0
  TO_PORT = 0
  SOURCE_SECURITY_GRP_ID = "${module.security_grp_elb.id}"
  PROTOCOL = -1
  SECURITY_GRP_ID = "${module.security_grp_ec2.id}"
  TYPE = "egress"
}

module "security_grp_rule_ec2_ingress_ssh" {
  source = "./../../../security-group-rule/cidr"
  TYPE = "ingress"
  SECURITY_GRP_ID = "${module.security_grp_ec2.id}"
  TO_PORT = 22
  FROM_PORT = 22
  PROTOCOL = "tcp"
  CIDR_BLOCKS = ["0.0.0.0/0"]
}

module "security_grp_rule_ec2_ingress_web" {
  source = "./../../../security-group-rule/source_security_grp"
  FROM_PORT = 80
  PROTOCOL = "tcp"
  TO_PORT = 80
  SECURITY_GRP_ID = "${module.security_grp_ec2.id}"
  SOURCE_SECURITY_GRP_ID = "${module.security_grp_elb.id}"
  TYPE = "ingress"
}

module "security_grp_elb" {
  source = "./../../../security-group"
  SECURITY_GRP_NAME = "elb-security-grp"
  SECURITY_GRP_DESCRIPTION = "elb secutiry group"
  VPC_ID = "${module.vpc.vpc_id}"
}

module "security_grp_rule_elb_egress" {
  source = "./../../../security-group-rule/cidr"
  FROM_PORT = 0
  TO_PORT = 0
  CIDR_BLOCKS = ["0.0.0.0/0"]
  PROTOCOL = -1
  SECURITY_GRP_ID = "${module.security_grp_elb.id}"
  TYPE = "egress"
}

module "security_grp_rule_elb_ingress_web" {
  source = "./../../../security-group-rule/cidr"
  FROM_PORT = 80
  PROTOCOL = "tcp"
  TO_PORT = 80
  SECURITY_GRP_ID = "${module.security_grp_elb.id}"
  CIDR_BLOCKS = ["0.0.0.0/0"]
  TYPE = "ingress"
}

module "asg" {
  source = "./../../../asg"
  VPC_ZONE_IDENTIFIER = ["${module.vpc.subnet-public-1b-id}", "${module.vpc.subnet-public-1a-id}"]
  SECURITY_GRPS = ["${module.security_grp_ec2.id}"]
  AWS_KEY = "${module.key.key_name}"
  LOAD_BALANCERS = ["${module.elb.load_balancer_name}"]
  AMI_ID = "${lookup(var.AMIS, var.AWS_REGION)}"
  FILE_NAME = "script.sh"
  HEALTHCHK_TYPE = "ELB"
  MAX_SIZE = 2
  MIN_SIZE = 2
}
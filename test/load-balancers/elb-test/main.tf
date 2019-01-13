module "elb" {
  source = "./../../../load-balancers/elb"
  SECURITY_GRPS = ["${aws_security_group.elb-securitygrp.id}"]
  SUBNETS = ["${module.vpc.subnet-public-1a-id}", "${module.vpc.subnet-public-1b-id}"]
}

module "vpc" {
  source = "./../../../vpc"
}

module "key" {
  source = "./../../../key"
}

module "asg" {
  source = "./../../../asg"
  VPC_ZONE_IDENTIFIER = ["${module.vpc.subnet-public-1b-id}", "${module.vpc.subnet-public-1a-id}"]
  SECURITY_GRPS = ["${module.vpc.ec2-instance-security-grp}"]
  AWS_KEY = "${module.key.key_name}"
  LOAD_BALANCERS = ["${module.elb.load_balancer_name}"]
  AMI_ID = "${lookup(var.AMIS, var.AWS_REGION)}"
  FILE_NAME = "script.sh"
  HEALTHCHK_TYPE = "ELB"
  MAX_SIZE = 2
  MIN_SIZE = 2
}
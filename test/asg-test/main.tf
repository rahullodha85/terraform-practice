module "auto_scaling" {
  source = "./../../asg"
  AMI_ID = "${lookup(var.AMIS, var.AWS_REGION)}"
  SECURITY_GRPS = ["${module.vpc.ec2-instance-security-grp}"]
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
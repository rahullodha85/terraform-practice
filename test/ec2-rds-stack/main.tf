module "ec2-instance" {
  source = "./../../ec2-standalone"
  SUBNET_ID = "${module.vpc.subnet-public-1a-id}"
  VPC_SECURITY_GRPS = ["${module.vpc.ec2-instance-security-grp}"]
  CLOUD_INIT_TEMPLATE = "${module.storage.cloudinit-storage-template}"
  SECURITY_GRPS = ["${module.vpc.ec2-instance-security-grp}"]
  EBS_VOLUME_ID = "${module.storage.ebs-volume-id}"
  AWS_REGION = "${var.AWS_REGION}"
  KEY_NAME = "${module.key.key_name}"
}

module "vpc" {
  source = "./../../vpc"
}

module "storage" {
  source = "./../../storage"
}

module "storage-attachment" {
  source = "./../../storage-attachment"
  EBS_VOLUME_ID = "${module.storage.ebs-volume-id}"
  EC2_INSTANCE_ID = "${module.ec2-instance.id}"
}

module "rds" {
  source = "./../../rds"
  MARIADB_PASSWORD = "${var.MARIADB_PASSWORD}"
  MARIADB_SECURITY_GRP_ID = ["${module.vpc.mariadb-security-grp-id}"]
  PREFERRED_MARIADB_AVAILABILITY_ZONE = "${module.vpc.subnet-private-1a-availability-zone}"
  MARIADB_SECURITY_GRP_ID_LIST = ["${module.vpc.subnet-private-1a-id}", "${module.vpc.subnet-private-1b-id}"]
}

module "key" {
  source = "./../../key"
  PATH_TO_PUBLIC_KEY = "${var.PATH_TO_PUBLIC_KEY}"
}

module "ec2-security-grp" {
  source = "./../../security-group"
  VPC_ID = "${module.vpc.vpc_id}"
  SECURITY_GRP_DESCRIPTION = "ec2-instance security group"
  SECURITY_GRP_NAME = "ec2-security-grp"
}

module "ec2-egress" {
  source = "./../../security-group-rule/cidr"
  SECURITY_GRP_ID = "${module.ec2-security-grp.id}"
  FROM_PORT = 0
  PROTOCOL = -1
  TYPE = "egress"
  CIDR_BLOCKS = ["0.0.0.0/0"]
  TO_PORT = 0
}

module "ec2-ingress-ssh" {
  source = "./../../security-group-rule/cidr"
  FROM_PORT = 22
  CIDR_BLOCKS = ["0.0.0.0/0"]
  PROTOCOL = "tcp"
  TYPE = "ingress"
  SECURITY_GRP_ID = "${module.ec2-security-grp.id}"
  TO_PORT = 22
}

module "ec2-ingress-web" {
  source = "./../../security-group-rule/cidr"
  FROM_PORT = 80
  CIDR_BLOCKS = ["0.0.0.0/0"]
  PROTOCOL = "tcp"
  TYPE = "ingress"
  SECURITY_GRP_ID = "${module.ec2-security-grp.id}"
  TO_PORT = 80
}

module "rds-security-grp" {
  source = "./../../security-group"
  SECURITY_GRP_NAME = "rds-security-grp"
  VPC_ID = "${module.vpc.vpc_id}"
  SECURITY_GRP_DESCRIPTION = "rds security group"
}

module "rds-ingress" {
  source = "./../../security-group-rule/source_security_grp"
  FROM_PORT = 3306
  TO_PORT = 3306
  TYPE = "ingress"
  PROTOCOL = "tcp"
  SOURCE_SECURITY_GRP_ID = "${module.ec2-security-grp.id}"
  SECURITY_GRP_ID = "${module.rds-security-grp.id}"
}
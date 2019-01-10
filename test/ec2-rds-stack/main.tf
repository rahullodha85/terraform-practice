module "ec2-instance" {
  source = "./../ec2-standalone"
  SUBNET_ID = "${module.vpc.subnet-public-1a-id}"
  VPC_SECURITY_GRPS = ["${module.vpc.ec2-instance-security-grp}"]
  CLOUD_INIT_TEMPLATE = "${module.storage.cloudinit-storage-template}"
  SECURITY_GRPS = ["${module.vpc.ec2-instance-security-grp}"]
  EBS_VOLUME_ID = "${module.storage.ebs-volume-id}"
  AWS_REGION = "${var.AWS_REGION}"
  KEY_NAME = "${module.key.key_name}"
}

module "vpc" {
  source = "./../vpc"
}

module "storage" {
  source = "./../storage"
}

module "storage-attachment" {
  source = "./../storage-attachment"
  EBS_VOLUME_ID = "${module.storage.ebs-volume-id}"
  EC2_INSTANCE_ID = "${module.ec2-instance.id}"
}

module "rds" {
  source = "./../rds"
  MARIADB_PASSWORD = "${var.MARIADB_PASSWORD}"
  MARIADB_SECURITY_GRP_ID = ["${module.vpc.mariadb-security-grp-id}"]
  PREFERRED_MARIADB_AVAILABILITY_ZONE = "${module.vpc.subnet-private-1a-availability-zone}"
  MARIADB_SECURITY_GRP_ID_LIST = ["${module.vpc.subnet-private-1a-id}", "${module.vpc.subnet-private-1b-id}"]
}

module "key" {
  source = "./../key"
  PATH_TO_PUBLIC_KEY = "${var.PATH_TO_PUBLIC_KEY}"
}
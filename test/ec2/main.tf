module "data-queries" {
  source = "../../data-queries"
  COUNT  = var.COUNT
}

module "ec2-instance" {
  source            = "../../ec2-standalone"
  VPC_SECURITY_GRPS = [aws_security_group.ec2_sg.id]
  KEY_NAME          = module.key.key_name
  AWS_REGION        = var.AWS_REGION
  USER_DATA         = file("${path.module}/script.sh")
  INSTANCE_COUNT    = var.COUNT
  AVAILABILITY_ZONE = module.data-queries.availability-zones
  SUBNET_ID         = module.data-queries.tf-vpc-subnet-public
  MY_AMI            = var.MY_AMI
}

module "key" {
  source = "./../../key"
  PATH_TO_PUBLIC_KEY = "${path.module}/my_aws_key.pub"
  PATH_TO_PRIVATE_KEY = "${path.module}/my_aws_key"
}

provider "aws" {
  region = var.AWS_REGION
  default_tags {
    tags = {
      Name = "ec2-test"
    }
  }
}

resource "aws_security_group" "ec2_sg" {
  name = "ec2_sg"
  vpc_id = module.data-queries.vpc-main
  description = "ec2_sg for testing"

  # ingress rules
  ingress {
    description = "SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  ingress {
    description = "HTTP from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }

  egress {
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
}

output "instance_ids" {
  value = module.ec2-instance.id[var.COUNT - 1]
}

terraform {
  backend "s3" {
    bucket = "rogue-bucket"
    key    = "terraform/ec2-test"
    region = "us-east-1"
  }
}

module "auto_scaling" {
  source              = "./../../asg"
  AMI_ID              = var.AMIS[var.AWS_REGION]
  SECURITY_GRPS       = [aws_security_group.ec2_sg.id]
  VPC_ZONE_IDENTIFIER = module.data-queries.tf-vpc-subnet-public
  AWS_KEY             = module.key.key_name
  FILE_NAME           = "script.sh"
  HEALTHCHK_TYPE      = "EC2"
  MAX_SIZE            = var.INSTANCE_COUNT
  TARGET_GROUP_ARNS   = []
  USER_DATA           = file("${path.module}/script.sh")
}

module "data-queries" {
  source = "../../data-queries"
  COUNT  = var.INSTANCE_COUNT
}

module "key" {
  source             = "./../../key"
  PATH_TO_PUBLIC_KEY = var.PATH_TO_PUBLIC_KEY
}

resource "aws_security_group" "ec2_sg" {
  name   = "${var.NAME}-ec2-sg"
  vpc_id = module.data-queries.vpc-main

  # egress rules
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress rules
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

provider "aws" {
  region = var.AWS_REGION

  default_tags {
    tags = {
      Name = "asg-test"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "rogue-bucket"
    key    = "terraform/asg"
    region = "us-east-1"
  }
}


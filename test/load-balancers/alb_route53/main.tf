terraform {
  backend "s3" {
    bucket = "rogue-bucket"
    key    = "terraform/elb-asg"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.AWS_REGION
  default_tags {
    tags = {
      Name = "alb-test"
    }
  }
}

module "data-queries" {
  source = "../../../data-queries"
  COUNT  = var.INSTANCE_COUNT + 1
}

module "ec2-instance" {
  source            = "../../../ec2-standalone"
  VPC_SECURITY_GRPS = [aws_security_group.alb_sg.id]
  KEY_NAME          = module.key.key_name
  AWS_REGION        = var.AWS_REGION
  USER_DATA         = file("${path.module}/script.sh")
  INSTANCE_COUNT    = var.INSTANCE_COUNT
  AVAILABILITY_ZONE = module.data-queries.availability-zones
  SUBNET_ID         = module.data-queries.tf-vpc-subnet-public
  MY_AMI            = var.MY_AMI
}

module "key" {
  source              = "./../../../key"
  PATH_TO_PUBLIC_KEY  = "${path.module}/my_aws_key.pub"
  PATH_TO_PRIVATE_KEY = "${path.module}/my_aws_key"
}

resource "aws_route53_record" "alb_test" {
  name    = "${var.NAME}.${module.data-queries.route53_zone_name}"
  type    = "A"
  zone_id = module.data-queries.route53_zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
  }
}

resource "aws_alb" "alb" {
  name            = "${var.NAME}-lb"
  internal        = var.INTERNAL
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = module.data-queries.tf-vpc-subnet-public
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = var.ALB_PORT
  protocol          = var.ALB_PROTOCOL

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group.arn
  }
}

resource "aws_alb_target_group" "target_group" {
  name        = "${var.NAME}-tg"
  port        = var.TG_PORT
  protocol    = var.TG_PROTOCOL
  vpc_id      = module.data-queries.vpc-main
  target_type = "instance"

  health_check {
    path     = "/"
    port     = var.TG_PORT
    protocol = var.TG_PROTOCOL
  }
}

resource "aws_alb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_alb_target_group.target_group.arn
  target_id        = module.ec2-instance.id[var.INSTANCE_COUNT - 1]
}

resource "aws_security_group" "alb_sg" {
  name   = "${var.NAME}-alb-sg"
  vpc_id = module.data-queries.vpc-main

  # ingress rules
  ingress {
    description = "HTTP from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = var.ALB_PORT
    to_port     = var.ALB_PORT
    protocol    = "tcp"
  }

  ingress {
    description = "SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  #egress rules
  egress {
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

variable "NAME" {
  default = "my-test"
}

variable "ALB_PORT" {
  type    = number
  default = 80
}

variable "TG_PORT" {
  type    = number
  default = 80
}

variable "ALB_PROTOCOL" {
  default = "HTTP"
}

variable "TG_PROTOCOL" {
  default = "HTTP"
}

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "INTERNAL" {
  type    = bool
  default = false
}

variable "INSTANCE_COUNT" {
  type    = number
  default = 1
}

variable "MY_AMI" {
  default = "ami-0039a1a6250e023b8"
}

output "load_balancer_name" {
  value = aws_alb.alb.name
}

output "load_balancer_dns_name" {
  value = aws_alb.alb.dns_name
}

output "load_balancer_arn" {
  value = aws_alb.alb.arn
}

output "route53_record" {
  value = aws_route53_record.alb_test.fqdn
}


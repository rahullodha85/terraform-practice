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
  name            = "${var.NAME}-alb"
  internal        = false
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

resource "aws_security_group" "alb_sg" {
  name   = "${var.NAME}-alb-sg"
  vpc_id = module.data-queries.vpc-main

  # egress rules
  egress {
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  # ingress rules
  ingress {
    description = "HTTP from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = var.ALB_PORT
    to_port     = var.ALB_PORT
    protocol    = "tcp"
  }
}

module "data-queries" {
  source = "../../../data-queries"
  COUNT  = var.INSTANCE_COUNT
}

module "key" {
  source = "./../../../key"
}

module "asg" {
  source              = "./../../../asg"
  VPC_ZONE_IDENTIFIER = module.data-queries.tf-vpc-subnet-public
  SECURITY_GRPS       = [aws_security_group.ec2_sg.id]
  AWS_KEY             = module.key.key_name
  #   LOAD_BALANCERS      = [aws_alb.alb.id]
  AMI_ID            = var.AMIS[var.AWS_REGION]
  FILE_NAME         = "script.sh"
  HEALTHCHK_TYPE    = "ELB"
  MAX_SIZE          = 3
  MIN_SIZE          = var.INSTANCE_COUNT
  USER_DATA         = file("${path.module}/script.sh")
  TARGET_GROUP_ARNS = [aws_alb_target_group.target_group.arn]
}

resource "aws_security_group" "ec2_sg" {
  name   = "${var.NAME}-ec2-sg"
  vpc_id = module.data-queries.vpc-main

  # ingress
  ingress {
    description = "SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    description = "HTTP from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = var.TG_PORT
    to_port     = var.TG_PORT
    protocol    = "tcp"
  }

  # egress
  egress {
    description = "Allow all outbound traffic"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

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
      Name = "alb-asg-route53-test"
    }
  }
}


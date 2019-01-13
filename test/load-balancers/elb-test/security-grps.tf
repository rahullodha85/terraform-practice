resource "aws_security_group" "myinstance" {
  vpc_id = "${module.vpc.vpc_id}"
  name = "myinstance"
  description = "Security group for my instance"
  tags {
    Name = "myinstance"
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    security_groups = ["${aws_security_group.elb-securitygrp.id}"]
  }
}

resource "aws_security_group" "elb-securitygrp" {
  vpc_id = "${module.vpc.vpc_id}"
  name = "elb-securitygrp"
  description = "Security group for my load balancer"
  tags {
    Name = "elb-securitygrp"
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}
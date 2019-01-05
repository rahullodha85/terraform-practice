resource "aws_security_group" "ec2-instance-security-grp" {
  vpc_id = "${aws_vpc.tf-main.id}"
  name = "tf-security-grp"
  description = "secutiry group"
//  egress {
//    from_port = 0
//    protocol = "-1"
//    to_port = 0
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//  ingress {
//    from_port = 80
//    protocol = "tcp"
//    to_port = 80
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//  ingress {
//    from_port = 22
//    protocol = "tcp"
//    to_port = 22
//    cidr_blocks = ["0.0.0.0/0"]
//  }
}

resource "aws_security_group_rule" "stand-alone-instance-egress" {
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.ec2-instance-security-grp.id}"
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
  type = "egress"
  description = "egress for ec2 stand-alone instance"
}

resource "aws_security_group_rule" "stand-alone-instance-ingress-web" {
  from_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.ec2-instance-security-grp.id}"
  to_port = 80
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
  description = "web traffic ingress for ec2 stand-alone instance"
}

resource "aws_security_group_rule" "stand-alone-instance-ingress-ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.ec2-instance-security-grp.id}"
  to_port = 22
  cidr_blocks = ["0.0.0.0/0"]
  type = "ingress"
  description = "ssh traffic for ec2 stand-alone instance"
}
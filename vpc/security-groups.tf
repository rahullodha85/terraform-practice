resource "aws_security_group" "ec2-instance-security-grp" {
  vpc_id = "${aws_vpc.tf-main.id}"
  name = "ec2-instance-security-grp"
  description = "ec2-instance secutiry group"
  tags {
      Name = "ec2 instancd security group"
  }
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

resource "aws_security_group" "allow_mariadb" {
  vpc_id = "${aws_vpc.tf-main.id}"
  name = "allow-mariadb"
  description = "mariadb secutiry group"
  tags {
    Name = "mariadb secutiry group"
  }
}

resource "aws_security_group_rule" "allow_mariadb_ingress" {
  from_port = 3306
  protocol = "tcp"
  security_group_id = "${aws_security_group.allow_mariadb.id}"
  to_port = 3306
  type = "ingress"
  source_security_group_id = "${aws_security_group.ec2-instance-security-grp.id}"
}
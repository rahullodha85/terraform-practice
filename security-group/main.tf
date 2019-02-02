resource "aws_security_group" "security-group" {
  vpc_id = "${var.VPC_ID}"
  name = "${var.SECURITY_GRP_NAME}"
  description = "${var.SECURITY_GRP_DESCRIPTION}"
}
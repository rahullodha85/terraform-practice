resource "aws_security_group_rule" "security-grp-rule" {
  from_port         = var.FROM_PORT
  protocol          = var.PROTOCOL
  security_group_id = var.SECURITY_GRP_ID
  to_port           = var.TO_PORT
  type              = var.TYPE
  cidr_blocks       = var.CIDR_BLOCKS
}


resource "aws_security_group_rule" "security-grp-rule-with-source" {
  from_port = "${var.FROM_PORT}"
  protocol = "${var.PROTOCOL}"
  security_group_id = "${var.SECURITY_GRP_ID}"
  to_port = "${var.TO_PORT}"
  type = "${var.TYPE}"
  source_security_group_id = "${var.SOURCE_SECURITY_GRP_ID}"
}
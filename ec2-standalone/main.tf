resource "aws_instance" "stand-alone" {
  ami = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "${var.INSTANCE_SIZE}"
}
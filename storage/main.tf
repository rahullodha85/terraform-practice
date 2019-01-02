resource "aws_ebs_volume" "ebs-volume-1" {
  availability_zone = "${var.AVAILABILITY_ZONE}"
  size = 10
  type = "gp2"
  tags {
    Name = "extra volume data"
  }
}

output "ebs-volume-id" {
  value = "${aws_ebs_volume.ebs-volume-1.id}"
}
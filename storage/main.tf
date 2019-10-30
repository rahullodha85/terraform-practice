resource "aws_ebs_volume" "ebs-volume-1" {
  count             = var.INSTANCE_COUNT
  availability_zone = element(var.AVAILABILITY_ZONE, count.index)
  size              = var.VOLUME_SIZE
  type              = "gp2"

  tags = {
    Name = "extra volume data"
  }
}

output "ebs-volume-id" {
  value = aws_ebs_volume.ebs-volume-1.*.id
}


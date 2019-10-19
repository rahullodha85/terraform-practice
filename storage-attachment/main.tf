resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  count        = var.INSTANCE_COUNT
  device_name  = "/dev/xvdh"
  instance_id  = element(var.EC2_INSTANCE_ID, count.index)
  volume_id    = element(var.EBS_VOLUME_ID, count.index)
  skip_destroy = true
}


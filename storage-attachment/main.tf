resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  device_name = "/dev/xvdh"
  instance_id = "${var.EC2_INSTANCE_ID}"
  volume_id = "${var.EBS_VOLUME_ID}"
  skip_destroy = true
}
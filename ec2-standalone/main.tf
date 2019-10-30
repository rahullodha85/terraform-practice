resource "aws_instance" "stand-alone" {
  ami                         = var.MY_AMI   //var.AMIS[var.AWS_REGION]
  instance_type               = var.INSTANCE_SIZE
  key_name                    = var.KEY_NAME
  subnet_id                   = var.SUBNET_ID[count.index]
  vpc_security_group_ids      = var.VPC_SECURITY_GRPS
  user_data                   = var.USER_DATA
  availability_zone           = element(var.AVAILABILITY_ZONE, count.index)
  count                       = var.INSTANCE_COUNT
  associate_public_ip_address = var.ASSOCIATE_PUBLIC_IP_ADDRESS
  //  provisioner "file" {
  //    source      = "${path.module}/script.sh"
  //    destination = "/tmp/script.sh"
  //  }
  //
  //  provisioner "remote-exec" {
  //    inline = [
  //      "chmod +x /tmp/script.sh",
  //      "sudo /tmp/script.sh",
  //    ]
  //  }
  //
  //  connection {
  //    user        = "${var.INSTANCE_USER}"
  //    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
  //  }
}


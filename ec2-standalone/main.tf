resource "aws_instance" "stand-alone" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "${var.INSTANCE_SIZE}"
  key_name      = "${var.KEY_NAME}"
  subnet_id     = "${var.SUBNET_ID}"
  vpc_security_group_ids = ["${var.VPC_SECURITY_GRPS}"]
  user_data = "${var.USER_DATA}"
  security_groups = ["${var.SECURITY_GRPS}"]

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

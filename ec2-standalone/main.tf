module "my-vpc" {
  source = "./../vpc"
}

module "ebs-volume" {
  source = "./../storage"
}

resource "aws_instance" "stand-alone" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "${var.INSTANCE_SIZE}"
  key_name      = "${aws_key_pair.my_aws_key.key_name}"
  subnet_id     = "${module.my-vpc.subnet-public-1a-id}"
  vpc_security_group_ids = ["${aws_security_group.tf-security-grp.id}"]
  user_data = "${module.ebs-volume.cloudinit-storage-template}"

//  provisioner "file" {
//    source      = "script.sh"
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

resource "aws_key_pair" "my_aws_key" {
  key_name   = "my_aws_key"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  device_name = "/dev/xvdh"
  instance_id = "${aws_instance.stand-alone.id}"
  volume_id = "${module.ebs-volume.ebs-volume-id}"
  skip_destroy = true
}

output "public_ip" {
  value = "${aws_instance.stand-alone.public_ip}"
}

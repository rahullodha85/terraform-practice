resource "aws_instance" "stand-alone" {
  ami = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "${var.INSTANCE_SIZE}"
  key_name = "${aws_key_pair.my_aws_key.key_name}"

  provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh"
    ]
  }

  connection {
    user = "${var.INSTANCE_USER}"
    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }
}

resource "aws_key_pair" "my_aws_key" {
  key_name = "my_aws_key"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

output "public_ip" {
  value = "${aws_instance.stand-alone.public_ip}"
}
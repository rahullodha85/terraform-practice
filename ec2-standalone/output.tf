output "public_ip" {
  value = "${aws_instance.stand-alone.*.public_ip}"
}

output "id" {
  value = "${aws_instance.stand-alone.*.id}"
}
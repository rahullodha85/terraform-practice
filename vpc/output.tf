output "vpc_id" {
  value = "${aws_vpc.tf-main.id}"
}

output "subnet-public-1a-id" {
  value = "${aws_subnet.tf-main-public-1.id}"
}

output "subnet-public-1b-id" {
  value = "${aws_subnet.tf-main-public-2.id}"
}

output "subnet-public-1c-id" {
  value = "${aws_subnet.tf-main-public-3.id}"
}

output "subnet-private-1a-id" {
  value = "${aws_subnet.tf-main-private-1.id}"
}

output "subnet-private-1b-id" {
  value = "${aws_subnet.tf-main-private-2.id}"
}

output "subnet-private-1c-id" {
  value = "${aws_subnet.tf-main-private-3.id}"
}
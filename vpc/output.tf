output "vpc_id" {
  value = aws_vpc.tf-main.id
}

output "subnet-public-1a-id" {
  value = aws_subnet.tf-main-public-1.id
}

output "subnet-public-1b-id" {
  value = aws_subnet.tf-main-public-2.id
}

output "subnet-public-1c-id" {
  value = aws_subnet.tf-main-public-3.id
}

output "subnet-private-1a-id" {
  value = aws_subnet.tf-main-private-1.id
}

output "subnet-private-1b-id" {
  value = aws_subnet.tf-main-private-2.id
}

output "subnet-private-1c-id" {
  value = aws_subnet.tf-main-private-3.id
}

output "subnet-public-1a-availability-zone" {
  value = aws_subnet.tf-main-public-1.availability_zone
}

output "subnet-public-1b-availability-zone" {
  value = aws_subnet.tf-main-public-2.availability_zone
}

output "subnet-public-1c-availability-zone" {
  value = aws_subnet.tf-main-public-3.availability_zone
}

output "subnet-private-1a-availability-zone" {
  value = aws_subnet.tf-main-private-1.availability_zone
}

output "subnet-private-1b-availability-zone" {
  value = aws_subnet.tf-main-private-2.availability_zone
}

output "subnet-private-1c-availability-zone" {
  value = aws_subnet.tf-main-private-3.availability_zone
}

output "route-table" {
  value = aws_route_table.tf-main-public.*.id
}

//output "ec2-instance-security-grp" {
//  value = "${aws_security_group.ec2-instance-security-grp.id}"
//}
//
//output "mariadb-security-grp-id" {
//  value = "${aws_security_group.allow_mariadb.id}"
//}

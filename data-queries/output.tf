output "vpc-main" {
  value = data.aws_vpc.default.id
}

output "tf-vpc-subnet-public" {
  value = data.aws_subnet.subnet.*.id
}

output "availability-zones" {
  value = data.aws_availability_zones.availability-zones.names
}


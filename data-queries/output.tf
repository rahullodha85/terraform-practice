output "vpc-main" {
  value = data.aws_vpc.default.id
}

output "tf-vpc-subnet-public" {
  value = data.aws_subnet.subnet.*.id
}

output "tf-vpc-subnet-private" {
  value = data.aws_subnet.subnet_private.*.id
}

output "availability-zones" {
  value = data.aws_availability_zones.availability-zones.names
}

output "main_public_route_table" {
  value = data.aws_route_table.main_public.id
}


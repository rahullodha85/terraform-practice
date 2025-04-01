output "vpc-main" {
  value = data.aws_vpc.default.id
}

output "tf-vpc-subnet-public" {
  value = data.aws_subnet.subnet.*.id
}

output "availability-zones" {
  value = data.aws_availability_zones.availability-zones.names
}

output "route53_zone_id" {
  value = data.aws_route53_zone.rahul_aws.id
}

output "route53_zone_name" {
  value = data.aws_route53_zone.rahul_aws.name
}
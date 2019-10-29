output "load_balancer_name" {
  value = aws_elb.my-elb.name
}

output "load_balancer_dns_name" {
  value = aws_elb.my-elb.dns_name
}


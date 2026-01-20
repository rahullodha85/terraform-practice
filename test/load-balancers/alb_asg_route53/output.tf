output "route53_fqdn" {
  value = aws_route53_record.alb_test.fqdn
}

output "load_balancer_dns_name" {
  value = aws_alb.alb.dns_name
}


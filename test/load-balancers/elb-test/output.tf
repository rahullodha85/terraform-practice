output "load_balancer_url" {
  value = module.elb.load_balancer_name
}

output "load_balancer_dns_name" {
  value = module.elb.load_balancer_dns_name
}


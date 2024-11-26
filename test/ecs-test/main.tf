module "ecs" {
  source = "../../ecs"
  fast_api_1_env_vars = "${path.module}/fast_api_1_env_vars.yml"
  fast_api_2_env_vars = "${path.module}/fast_api_2_env_vars.yml"
  route_table_id = module.data-queries.main_public_route_table
#   subnet_id = module.data-queries.tf-vpc-subnet-private.0
  subnet_id = module.data-queries.tf-vpc-subnet-public.0
  vpc_id = module.data-queries.vpc-main
  image_tag = "0.0.6"
}

module "data-queries" {
  source = "../../data-queries"
  COUNT  = 1
}

data "aws_route53_zone" "selected" {
  name         = var.route53_name
}

resource "aws_route53_record" "alb_record" {
  name    = "fast-api.${var.route53_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.selected.zone_id
  alias {
    evaluate_target_health = true
    name                   = module.ecs.alb.dns_name
    zone_id                = module.ecs.alb.zone_id
  }
}

output "alb_dns_name" {
  value = module.ecs.alb.dns_name
}

variable "route53_name" {}

output "route53_name" {
  value = data.aws_route53_zone.selected.name
}
module "ecs" {
  source = "../../ecs"
  fast_api_env_vars = "${path.module}/fast_api_env_vars.yml"
}
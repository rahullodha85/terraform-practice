module "lambda" {
  source = "../../lambda"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
  output_path = "./output.zip"
  policy-actions = ["s3:ListBucket"]
  resources = ["arn:aws:s3:::micro-frontend-1", "arn:aws:s3:::micro-frontend-1/*"]
  role_name = "rds-user-lambda"
  source_file = "./output/app"
  trusted_resource = "lambda.amazonaws.com"
  function_name = "rds-user"
  handler = "app"
  runtime = "go1.x"
  subnet_ids = module.vpc.tf-vpc-subnet-public
  vpc_id = module.vpc.vpc-main
}

module "vpc" {
  source = "./../../data-queries"
  COUNT = 3
}

data "aws_lambda_invocation" "lambda_invoke" {
  depends_on = [module.lambda]
  function_name = module.lambda.function_name
  input         = jsonencode({
    username = "test_user"
    password = "test12345"
  })

  lifecycle {
    postcondition {
      condition = jsondecode(self.result)["statusCode"] == 200
      error_message = "lambda execution failure"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

output "response" {
  value = jsondecode(data.aws_lambda_invocation.lambda_invoke.result)
}
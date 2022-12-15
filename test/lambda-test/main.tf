module "lambda" {
  source = "../../lambda"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  output_path = "./output.zip"
  policy-actions = ["s3:ListBucket"]
  resources = ["arn:aws:s3:::micro-frontend-1", "arn:aws:s3:::micro-frontend-1/*"]
  role_name = "rds-user-lambda"
  source_file = "./src/output"
  trusted_resource = "lambda.amazonaws.com"
}

provider "aws" {
  region = "us-east-1"
}
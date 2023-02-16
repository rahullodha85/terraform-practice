module "lambda" {
  source = "../../lambda"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"]
  output_path = "./output.zip"
  policy-actions = ["s3:ListBucket"]
  resources = ["arn:aws:s3:::micro-frontend-1", "arn:aws:s3:::micro-frontend-1/*"]
  role_name = "golang-sts-lambda"
  source_file = "./output/app"
  trusted_resource = "lambda.amazonaws.com"
  function_name = "golang-sts-test"
  handler = "app"
  runtime = "go1.x"
  subnet_ids = module.vpc.tf-vpc-subnet-public
  vpc_id = module.vpc.vpc-main
}

module "vpc" {
  source = "./../../data-queries"
  COUNT = 3
}

//resource "aws_db_instance" "sql_server" {
//  allocated_storage = 100
//  engine = "sqlserver-se"
//  engine_version = "14.00.3451.2.v1"
//  instance_class = "db.m4.large"
//  identifier = "mssql"
//  name = null
//  username = "admin"
//  password = "test1234567890"
//  db_subnet_group_name = "${aws_db_subnet_group.mariadb-subnet.name}"
////  parameter_group_name = "${aws_db_parameter_group.mariadb-parameters.name}"
//  multi_az = "false"
//  vpc_security_group_ids = ["${module.lambda.lambda_sg}"]
//  storage_type = "gp2"
//  backup_retention_period = 30
//  skip_final_snapshot = true
//  license_model = "license-included"
////  tags {
////    Name = "mariadb-instance"
////  }
//}
//
////resource "aws_db_parameter_group" "mariadb-parameters" {
////  name = "mssql-parameters"
////  family = "mariadb10.3"
////  description = "MSSQL parameter group"
////  parameter {
////    name = ""
////    value = "16777216"
////  }
////}
//
//resource "aws_db_subnet_group" "mariadb-subnet" {
//  name = "mariadb-subnet"
//  description = "RDS mariadb subnet group"
//  subnet_ids = module.vpc.tf-vpc-subnet-public
//}

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
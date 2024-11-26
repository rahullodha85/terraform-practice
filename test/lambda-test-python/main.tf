resource "aws_iam_role" "iam_role" {
  name="rds-test-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  inline_policy {
    name="root"
    policy=data.aws_iam_policy_document.inline_policy.json
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions = ["s3:ListBucket"]
    resources = ["*"]
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = "rds-test"
  handler = "handler.lambda_handler"
  role = aws_iam_role.iam_role.arn
  runtime = "python3.7"
  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = base64sha256(data.archive_file.lambda_zip.output_path)
  layers = [aws_lambda_layer_version.lambda_layer.arn]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name = "rds-pyodbc-layer"
  source_code_hash = base64sha256(data.archive_file.lambda_layer_zip.output_path)
  filename = data.archive_file.lambda_layer_zip.output_path
}

data "archive_file" "lambda_zip" {
  output_path = "./output.zip"
  type = "zip"
  source_dir = "./src"
}

data "archive_file" "lambda_layer_zip" {
  output_path = "./output_layer.zip"
  type = "zip"
  source_dir = "./pyodbc-layer"
}

# Lambda Invoke

data "aws_lambda_invocation" "lambda_invoke" {
  function_name = aws_lambda_function.lambda.function_name
  input         = jsonencode({
    username = "test_user"
    password = "test12345"
  })
}

provider "aws" {
  region = "us-east-1"
}
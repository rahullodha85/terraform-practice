resource "aws_iam_role" "iam_role" {
  name=var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = var.trusted_resource
        }
      },
    ]
  })
  managed_policy_arns = var.managed_policy_arns

  inline_policy {
    name="root"
    policy=data.aws_iam_policy_document.inline_policy.json
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    actions = var.policy-actions
    resources = var.resources
  }
}
resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  handler = var.handler
  role = aws_iam_role.iam_role.arn
  runtime = var.runtime
  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = base64sha256(data.archive_file.lambda_zip.output_path)
  vpc_config {
    security_group_ids = [aws_security_group.lambda_sg.id, ]
    subnet_ids = var.subnet_ids
  }
}

resource "aws_security_group" "lambda_sg" {
  name = "${var.function_name}-sg"
  vpc_id = var.vpc_id
  egress {
    from_port = 0
    protocol = -1
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "archive_file" "lambda_zip" {
  output_path = var.output_path
  type = "zip"
  source_file = var.source_file
}
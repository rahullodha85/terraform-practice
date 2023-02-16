output "iam_role_arn" {
  value = aws_iam_role.iam_role.arn
}

output "lambda_sg" {
  value = aws_security_group.lambda_sg.id
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
}
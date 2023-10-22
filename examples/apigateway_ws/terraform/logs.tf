resource "aws_cloudwatch_log_group" "log_group_for_lambda" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 1
}

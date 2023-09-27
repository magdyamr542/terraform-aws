# Log group in cloudwatch to gather logs of the lambda functions.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group
resource "aws_cloudwatch_log_group" "log_group_for_lambda1" {
  name              = "/aws/lambda/${aws_lambda_function.lambda1.function_name}"
  retention_in_days = 1
}


resource "aws_cloudwatch_log_group" "log_group_for_lambda2" {
  name              = "/aws/lambda/${aws_lambda_function.lambda2.function_name}"
  retention_in_days = 1
}

resource "aws_iam_role" "iam_role_lambda2" {
  name               = "iam_role_lambda2"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "iam_role_policy_lambda2" {
  name = "iam_policy_for_lambda2"
  role = aws_iam_role.iam_role_lambda2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Enable the function to write logs.
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "lambda:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        # Enable the function to fetch messages from the queue.
        Action = [
          "sqs:ReceiveMessage",
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.app_queue.arn
      }
    ]
  })
}



data "archive_file" "archive_file_lambda2" {
  type        = "zip"
  source_file = "lambda2"
  output_path = "lambda2.zip"
}

resource "aws_lambda_function" "lambda2" {
  function_name    = "lambda2"
  role             = aws_iam_role.iam_role_lambda2.arn
  handler          = "lambda2"
  runtime          = "go1.x"
  filename         = "lambda2.zip"
  source_code_hash = data.archive_file.archive_file_lambda2.output_base64sha256
}

# Allows the lambda to get events from the queue.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping
resource "aws_lambda_event_source_mapping" "event_source_mapping_sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.app_queue.arn
  function_name    = aws_lambda_function.lambda2.arn
}

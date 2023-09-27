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
        # Enable the function to write logs to the configured log group.
        # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazoncloudwatchlogs.html
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.log_group_for_lambda2.arn
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
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.app_queue.arn
      }
    ]
  })
}

resource "null_resource" "build_lambda2_binary" {
  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${local.lambda2_binary_path} ${local.lambda2_src_path}"
  }
}

data "archive_file" "archive_file_lambda2" {
  type        = "zip"
  source_file = local.lambda2_binary_path
  output_path = local.lambda2_archive_path
  depends_on  = [null_resource.build_lambda2_binary]
}


resource "aws_lambda_function" "lambda2" {
  function_name    = "lambda2"
  description      = "The function gets by sqs and logs the message it receives"
  role             = aws_iam_role.iam_role_lambda2.arn
  handler          = local.binary_name
  runtime          = "go1.x"
  filename         = local.lambda2_archive_path
  source_code_hash = data.archive_file.archive_file_lambda2.output_base64sha256
}

# Allows the lambda to get events from the queue.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping
resource "aws_lambda_event_source_mapping" "event_source_mapping_sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.app_queue.arn
  function_name    = aws_lambda_function.lambda2.arn
}

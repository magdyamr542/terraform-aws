resource "aws_iam_role" "iam_role_lambda1" {
  name               = "iam_role_lambda1"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "iam_role_policy_lambda1" {
  name = "iam_policy_for_lambda1"
  role = aws_iam_role.iam_role_lambda1.id

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
        # Enable the function to read the object from s3.
        # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazons3.html
        Action = [
          "s3:GetObject",
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.app_bucket.arn
      },
      {
        # Enable the function to access the queue.
        # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonsqs.html
        Action = [
          "sqs:GetQueueUrl",
          "sqs:SendMessage",
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.app_queue.arn
      }
    ]
  })
}



data "archive_file" "archive_file_lambda1" {
  type        = "zip"
  source_file = "lambda1"
  output_path = "lambda1.zip"
}

resource "aws_lambda_function" "lambda1" {
  function_name    = "lambda1"
  role             = aws_iam_role.iam_role_lambda1.arn
  handler          = "lambda1"
  runtime          = "go1.x"
  filename         = "lambda1.zip"
  source_code_hash = data.archive_file.archive_file_lambda1.output_base64sha256
}

## This allows the s3 bucket to invoke the lambda function.
resource "aws_lambda_permission" "allow_bucket_execute_lambda1" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda1.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.app_bucket.arn
}

# This triggers an event from s3 to lambda. 
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.app_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda1.arn
    # Supported events:
    # https://docs.aws.amazon.com/AmazonS3/latest/userguide/notification-how-to-event-types-and-destinations.html#supported-notification-event-types
    events = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket_execute_lambda1]
}

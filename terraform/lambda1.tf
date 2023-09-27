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


# Build the lambda binary through a null_resource. It enables us to execute commands.
# This will write the binary to the value of ${local.lambda1_binary_path}
resource "null_resource" "build_lambda1_binary" {
  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${local.lambda1_binary_path} ${local.lambda1_src_path}"
  }
}

data "archive_file" "archive_file_lambda1" {
  type        = "zip"
  source_file = local.lambda1_binary_path
  output_path = local.lambda1_archive_path
  depends_on  = [null_resource.build_lambda1_binary]
}

resource "aws_lambda_function" "lambda1" {
  function_name    = "lambda1"
  description      = "The function gets triggered when an object is created in s3. It transforms its content and puts a message in sqs"
  role             = aws_iam_role.iam_role_lambda1.arn
  handler          = local.binary_name
  runtime          = "go1.x"
  filename         = local.lambda1_archive_path
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

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}



resource "aws_iam_role" "iam_role_for_chat_lambda" {
  name               = "iam_role_for_chat_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "iam_role_policy_for_chat_lambda" {
  name = "iam_policy_for_lambda"
  role = aws_iam_role.iam_role_for_chat_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = aws_cloudwatch_log_group.log_group_for_lambda.arn
      },
      {
        Action   = "lambda:*"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "null_resource" "build_chat_lambda_binary" {
  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${local.lambda_binary_path} ${local.lambda_src_path}"
  }
}

data "archive_file" "archive_file_chat_lambda" {
  type        = "zip"
  source_file = local.lambda_binary_path
  output_path = local.lambda_archive_path
  depends_on  = [null_resource.build_chat_lambda_binary]
}

resource "aws_lambda_function" "chat_lambda" {
  function_name    = local.lambda_name
  description      = "The chat lambda"
  role             = aws_iam_role.iam_role_for_chat_lambda.arn
  handler          = local.binary_name
  runtime          = "go1.x"
  filename         = local.lambda_archive_path
  source_code_hash = data.archive_file.archive_file_chat_lambda.output_base64sha256
  depends_on       = [aws_cloudwatch_log_group.log_group_for_lambda]
}

# ## This allows the s3 bucket to invoke the lambda function.
# resource "aws_lambda_permission" "allow_bucket_execute_lambda1" {
#   statement_id  = "AllowExecutionFromS3Bucket"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.lambda1.arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = aws_s3_bucket.app_bucket.arn
# }

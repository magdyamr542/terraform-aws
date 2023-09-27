# Lambda1
output "lambda1_arn" {
  value = aws_lambda_function.lambda1.arn
}
output "lambda1_id" {
  value = aws_lambda_function.lambda1.id
}

# Lambda2
output "lambda2_arn" {
  value = aws_lambda_function.lambda2.arn
}
output "lambda2_id" {
  value = aws_lambda_function.lambda2.id
}

# Bucket
output "bucket_arn" {
  value = aws_s3_bucket.app_bucket.arn
}
output "bucket_id" {
  value = aws_s3_bucket.app_bucket.id
}
output "bucket_domain_name" {
  value = aws_s3_bucket.app_bucket.bucket_domain_name
}

# Queue
output "queue_arn" {
  value = aws_sqs_queue.app_queue.arn
}
output "queue_id" {
  value = aws_sqs_queue.app_queue.id
}
output "queue_url" {
  value = aws_sqs_queue.app_queue.url
}

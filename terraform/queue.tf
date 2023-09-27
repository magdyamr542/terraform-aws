resource "aws_sqs_queue" "app_queue" {
  name                      = "app_queue"
  receive_wait_time_seconds = 10

  tags = {
    Environment = "production"
  }
}

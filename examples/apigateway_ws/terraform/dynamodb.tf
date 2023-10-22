resource "aws_dynamodb_table" "chat-table" {
  name           = "Chat"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "ConnectionId"
  range_key      = "ConnectionId"

  attribute {
    name = "ConnectionId"
    type = "S"
  }

  attribute {
    name = "ConnectionTimestamp"
    type = "S"
  }

  tags = {
    Name        = "chat-table"
    Environment = var.environment
  }
}

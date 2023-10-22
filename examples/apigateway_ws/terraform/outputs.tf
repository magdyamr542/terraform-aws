# Dynamodb
output "chat_table_arn" {
  value = aws_dynamodb_table.chat-table.arn
}
output "chat_table_id" {
  value = aws_dynamodb_table.chat-table.id
}

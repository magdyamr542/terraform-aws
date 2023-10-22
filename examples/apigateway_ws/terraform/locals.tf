
locals {
  binary_name         = "binary"
  lambda_src_path     = "../cmd/chat_lambda"
  lambda_binary_path  = "tf_generated/chat_lambda/binary"
  lambda_archive_path = "tf_generated/chat_lambda/binary.zip"
  lambda_name         = "chat_lambda"
}

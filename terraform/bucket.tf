
resource "aws_s3_bucket" "app_bucket" {
  bucket = "app_bucket"
  tags = {
    Name        = "app_bucket"
    Environment = "Development"
  }
}

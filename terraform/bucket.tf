
resource "aws_s3_bucket" "app_bucket" {
  bucket = "aws-s3-bucket-app-bucket-testing"
  tags = {
    Name        = "app_bucket"
    Environment = "Development"
  }
}

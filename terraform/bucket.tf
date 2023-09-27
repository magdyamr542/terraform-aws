
resource "aws_s3_bucket" "app_bucket" {
  bucket        = "aws-s3-bucket-app-bucket-testing"
  force_destroy = true
  tags = {
    Name        = "app_bucket"
    Environment = "Development"
  }
}


resource "aws_s3_bucket" "app_bucket_destination" {
  bucket        = "aws-s3-bucket-app-bucket-destination-testing"
  force_destroy = true
  tags = {
    Name        = "app_bucket_destination"
    Environment = "Development"
  }
}

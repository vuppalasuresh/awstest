provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-9898989secure-bucket-123456"
}

resource "aws_s3_bucket_acl" "private_acl" {
  bucket = aws_s3_bucket.secure_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Data source to validate bucket in test script
data "aws_s3_bucket" "secure_bucket" {
  bucket = aws_s3_bucket.secure_bucket.id
}

# terraform {
#   backend "s3" {
#     bucket = "my-9898989-123-secure-bucket-123456"
#     key    = "terraform.tfstate"
#     region = "us-east-1"
#     encrypt = true
#   }
# }


resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-9898989-1234-secure-bucket-123456"
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
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

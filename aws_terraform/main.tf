provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-12341234564-secure-bucket-123456"
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

# Automated Tests
test {
  check "bucket_exists" {
    assert {
      condition     = length(data.aws_s3_bucket.secure_bucket.id) > 0
      error_message = "S3 bucket does not exist."
    }
  }

  check "encryption_enabled" {
    assert {
      condition     = data.aws_s3_bucket.secure_bucket.server_side_encryption_configuration[0].rule[0].apply_server_side_encryption_by_default.sse_algorithm == "AES256"
      error_message = "S3 bucket encryption is not enabled or not using AES256."
    }
  }
}

# Data source to fetch bucket details for testing
data "aws_s3_bucket" "secure_bucket" {
  bucket = aws_s3_bucket.secure_bucket.id
}

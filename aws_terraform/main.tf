provider "aws" {
  region = "us-east-1"
}

# Create S3 bucket
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-123123432-secure-bucket-12345" # Change to a unique name
}

# Block public access
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable default encryption (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Test to verify S3 bucket exists and has the correct configuration
terraform {
  required_providers {
    test = {
      source  = "terraform.io/builtin/test"
    }
  }
}

resource "test_assertions" "verify_s3" {
  component = aws_s3_bucket.secure_bucket.id

  equal "exists" {
    description = "Check if S3 bucket exists"
    got         = aws_s3_bucket.secure_bucket.id
    want        = aws_s3_bucket.secure_bucket.id
  }

  equal "encryption_enabled" {
    description = "Check if S3 bucket encryption is enabled"
    got         = aws_s3_bucket_server_side_encryption_configuration.encryption.rule[0].apply_server_side_encryption_by_default.sse_algorithm
    want        = "AES256"
  }

  equal "public_access_blocked" {
    description = "Check if public access is blocked"
    got         = aws_s3_bucket_public_access_block.block_public.block_public_acls
    want        = true
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.secure_bucket.id
}

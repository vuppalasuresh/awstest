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

# Data source to fetch bucket details for validation
data "aws_s3_bucket" "secure_bucket" {
  bucket = "my-9898989-123-secure-bucket-123456"
}

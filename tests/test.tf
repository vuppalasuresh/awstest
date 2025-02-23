# Test encryption for the S3 bucket
resource "null_resource" "test_encryption" {
  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.encryption
  ]

  provisioner "local-exec" {
    command = <<EOT
      encryption_status=$(aws s3api get-bucket-encryption --bucket ${aws_s3_bucket.secure_bucket.bucket} --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text)
      if [ "$encryption_status" == "AES256" ]; then
        echo "Encryption is enabled with AES256."
      else
        echo "Encryption is not set to AES256."
        exit 1
      fi
    EOT
  }
}

# Test public access block for the S3 bucket
resource "null_resource" "test_public_access_block" {
  depends_on = [
    aws_s3_bucket_public_access_block.block_public_access
  ]

  provisioner "local-exec" {
    command = <<EOT
      public_access_block=$(aws s3api get-bucket-policy-status --bucket ${aws_s3_bucket.secure_bucket.bucket} --query 'PolicyStatus.IsPublic' --output text)
      if [ "$public_access_block" == "False" ]; then
        echo "Public access is properly blocked."
      else
        echo "Public access is not blocked."
        exit 1
      fi
    EOT
  }
}

output "test_encryption_status" {
  value = null_resource.test_encryption.*.id
}

output "test_public_access_block_status" {
  value = null_resource.test_public_access_block.*.id
}

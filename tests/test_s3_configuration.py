import boto3
import unittest
from botocore.exceptions import ClientError

class TestS3BucketConfiguration(unittest.TestCase):
    def setUp(self):
        # Set up the S3 client
        self.s3 = boto3.client('s3', region_name='us-east-1')
        self.bucket_name = 'my-9898989-123-secure-bucket-123456'

    def test_bucket_exists(self):
        """Test if the S3 bucket exists"""
        try:
            response = self.s3.head_bucket(Bucket=self.bucket_name)
            self.assertEqual(response['ResponseMetadata']['HTTPStatusCode'], 200)
        except ClientError as e:
            self.fail(f"Failed to access bucket {self.bucket_name}: {e}")

    def test_block_public_access(self):
        """Test if public access is blocked on the S3 bucket"""
        try:
            response = self.s3.get_bucket_policy_status(Bucket=self.bucket_name)
            is_public = response.get('PolicyStatus', {}).get('IsPublic', False)
            self.assertFalse(is_public, f"The bucket {self.bucket_name} is publicly accessible.")
        except ClientError as e:
            self.fail(f"Error checking public access on bucket {self.bucket_name}: {e}")

    def test_encryption_enabled(self):
        """Test if server-side encryption (AES256) is enabled on the S3 bucket"""
        try:
            response = self.s3.get_bucket_encryption(Bucket=self.bucket_name)
            encryption = response.get('ServerSideEncryptionConfiguration', {}).get('Rules', [])
            encryption_enabled = False

            for rule in encryption:
                sse_algorithm = rule.get('ApplyServerSideEncryptionByDefault', {}).get('SSEAlgorithm')
                if sse_algorithm == 'AES256':
                    encryption_enabled = True

            self.assertTrue(encryption_enabled, "AES256 encryption is not enabled on the bucket.")
        except ClientError as e:
            self.fail(f"Error checking encryption on bucket {self.bucket_name}: {e}")

if __name__ == '__main__':
    unittest.main()

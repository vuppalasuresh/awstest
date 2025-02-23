import unittest
import boto3
from botocore.exceptions import ClientError

class TestS3BucketConfiguration(unittest.TestCase):

    def setUp(self):
        # Set up AWS client and bucket details
        self.s3 = boto3.client('s3', region_name='us-east-1')
        self.bucket_name = "my-9898989-123-secure-bucket-123456"

    def test_encryption_enabled(self):
        """Test if AES256 encryption is enabled"""
        response = self.s3.get_bucket_encryption(Bucket=self.bucket_name)
        encryption_status = response.get('ServerSideEncryptionConfiguration', {}).get('Rules', [])
        self.assertTrue(len(encryption_status) > 0, "Encryption is not configured.")
        self.assertEqual(encryption_status[0]['ApplyServerSideEncryptionByDefault']['SSEAlgorithm'], 'AES256')

    def test_block_public_access(self):
        """Test if public access is blocked on the S3 bucket"""
        try:
            # Check if public access block configuration exists and is enabled
            response = self.s3.get_bucket_acl(Bucket=self.bucket_name)
            public_access = response.get('Grants', [])
            # Check if no public access grants are present
            self.assertFalse(any(grant['Grantee']['Type'] == 'CanonicalUser' for grant in public_access),
                             "Public access is not blocked.")
        except ClientError as e:
            self.fail(f"Error checking public access on bucket {self.bucket_name}: {e}")

    def test_bucket_exists(self):
        """Test if the S3 bucket exists"""
        response = self.s3.head_bucket(Bucket=self.bucket_name)
        self.assertEqual(response['ResponseMetadata']['HTTPStatusCode'], 200, "Bucket does not exist or is inaccessible.")

if __name__ == '__main__':
    unittest.main()

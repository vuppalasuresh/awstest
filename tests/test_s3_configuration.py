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
            response = self.s3.get_bucket_policy_status(Bucket=self.bucket_name)
            # If a policy exists, check if it's public
            public_access = response.get('PolicyStatus', {}).get('IsPublic', False)
            self.assertFalse(public_access, "Bucket has a public policy.")
        except ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchBucketPolicy':
                # If there is no policy, proceed to check block public access settings
                response = self.s3.get_bucket_policy(Bucket=self.bucket_name)
                self.assertTrue(response['Policy']['Statement'][0]['Effect'] == 'Deny', "Public access is not blocked.")
            else:
                self.fail(f"Error checking public access on bucket {self.bucket_name}: {e}")

    def test_bucket_exists(self):
        """Test if the S3 bucket exists"""
        response = self.s3.head_bucket(Bucket=self.bucket_name)
        self.assertEqual(response['ResponseMetadata']['HTTPStatusCode'], 200, "Bucket does not exist or is inaccessible.")

if __name__ == '__main__':
    unittest.main()

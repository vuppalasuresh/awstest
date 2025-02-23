import boto3
import unittest
from botocore.exceptions import ClientError

class TestS3BucketConfiguration(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        # Initialize the S3 client in us-east-1 region
        cls.s3 = boto3.client('s3', region_name='us-east-1')
        cls.bucket_name = 'my-9898989-1234-secure-bucket-123456'

    def test_bucket_exists(self):
        """Test if the bucket exists"""
        try:
            response = self.s3.head_bucket(Bucket=self.bucket_name)
            self.assertEqual(response['ResponseMetadata']['HTTPStatusCode'], 200)
        except ClientError as e:
            self.fail(f"Error checking if bucket exists: {e}")

    def test_encryption_enabled(self):
        """Test if AES256 encryption is enabled"""
        try:
            response = self.s3.get_bucket_encryption(Bucket=self.bucket_name)
            rules = response.get('ServerSideEncryptionConfiguration', {}).get('Rules', [])
            self.assertTrue(len(rules) > 0, "Encryption is not configured.")
            self.assertEqual(rules[0]['ApplyServerSideEncryptionByDefault']['SSEAlgorithm'], 'AES256')
        except ClientError as e:
            self.fail(f"Error checking bucket encryption: {e}")

    def test_block_public_access(self):
        """Test if the public access block is enabled on the bucket"""
        try:
            response = self.s3.get_public_access_block(Bucket=self.bucket_name)
            config = response.get("PublicAccessBlockConfiguration", {})
            self.assertTrue(config.get("BlockPublicAcls", False), "BlockPublicAcls is not enabled.")
            self.assertTrue(config.get("IgnorePublicAcls", False), "IgnorePublicAcls is not enabled.")
            self.assertTrue(config.get("BlockPublicPolicy", False), "BlockPublicPolicy is not enabled.")
            self.assertTrue(config.get("RestrictPublicBuckets", False), "RestrictPublicBuckets is not enabled.")
        except ClientError as e:
            self.fail(f"Error getting public access block configuration: {e}")

if __name__ == '__main__':
    unittest.main()

import boto3
import unittest
from botocore.exceptions import ClientError

class TestS3BucketConfiguration(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        # Initialize the S3 client
        cls.s3 = boto3.client('s3')
        cls.bucket_name = 'my-9898989-123-secure-bucket-123456'

    def test_bucket_exists(self):
        """Test if the bucket exists"""
        try:
            response = self.s3.head_bucket(Bucket=self.bucket_name)
            self.assertEqual(response['ResponseMetadata']['HTTPStatusCode'], 200)
        except ClientError as e:
            self.fail(f"Error checking if bucket exists: {e}")

    def test_block_public_access(self):
        """Test if the public access block is enabled on the bucket"""
        try:
            response = self.s3.get_bucket_policy_status(Bucket=self.bucket_name)
            self.assertTrue(response['PolicyStatus']['IsPublic'] is False, "Public access is not blocked.")
        except ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchBucketPolicy':
                self.fail("No bucket policy found, cannot check public access.")
            else:
                self.fail(f"Error checking public access: {e}")

    def test_acl_is_private(self):
        """Test if the ACL is private (no public access)"""
        try:
            response = self.s3.get_bucket_acl(Bucket=self.bucket_name)
            grantees = response['Grants']
            # Check if there are any public grants
            for grant in grantees:
                if grant['Grantee'].get('Type') == 'CanonicalUser' and 'URI' in grant['Grantee']:
                    self.fail("Bucket has public access grants.")
            self.assertTrue(True)
        except ClientError as e:
            self.fail(f"Error checking ACL: {e}")

if __name__ == '__main__':
    unittest.main()

# Flask App Deployment on AWS ECS (Fargate)

This project deploys a Flask application to AWS ECS using Fargate with Terraform. It provisions an ECS cluster, task definition, service, security group, and IAM roles.

## Prerequisites

- **Terraform** (latest version)
- **AWS CLI** (configured with the necessary permissions)
- **An existing ECR repository** (with the Flask app Docker image pushed)

## Resources Created
    ECS Cluster: flask-app-cluster
    ECS Task Definition: Uses the Flask app Docker image from ECR
    ECS Service: Runs the Flask app as a Fargate task
    Security Group: Allows HTTP traffic on port 5000
    IAM Roles: Grants necessary permissions for ECS and ECR access
    CloudWatch Log Group: Logs ECS container output


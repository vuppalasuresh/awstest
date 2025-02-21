# Terraform Configuration for AWS ECS Deployment

This repository contains Terraform scripts to provision an AWS ECS (Fargate) infrastructure for deploying a Flask application.

## Prerequisites

- **Terraform** (latest version)
- **AWS CLI** (configured with appropriate IAM permissions)
- **Existing ECR Repository** (Docker image should be pushed before deployment)

## Infrastructure Components

The Terraform configuration will create the following AWS resources:

- **ECS Cluster**: `flask-app-cluster`
- **ECS Task Definition**: Uses an ECR-hosted Docker image
- **ECS Service**: Runs the containerized Flask app on Fargate
- **Security Group**: Allows inbound HTTP traffic on port `80`
- **IAM Roles & Policies**: Grants ECS and ECR access
- **CloudWatch Logs**: Stores application logs
- **CloudWatch Alarm**: Monitors log activity


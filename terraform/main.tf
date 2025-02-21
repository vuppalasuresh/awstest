provider "aws" {
  region = "us-east-1"
}

# # Reference the existing ECR repository
# data "aws_ecr_repository" "my_ecr" {
#   repository_name = "my-flask-app"
# }

# Create IAM role for ECS tasks to interact with ECR
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy to the ECS task role for ECR access
resource "aws_iam_role_policy" "ecs_task_policy" {
  name   = "ecs-task-policy"
  role   = aws_iam_role.ecs_task_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Effect   = "Allow"
        Resource = data.aws_ecr_repository.my_ecr.arn
      }
    ]
  })
}

# Define the ECS Cluster
resource "aws_ecs_cluster" "flask_app_cluster" {
  name = "flask-app-cluster"
}

# Define the ECS task definition using the Docker image from the existing ECR repository
resource "aws_ecs_task_definition" "flask_task_definition" {
  family                   = "flask-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "flask-app-container"
      image     = "${data.aws_ecr_repository.my_ecr.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Create a security group for ECS tasks (allow traffic on port 80)
resource "aws_security_group" "ecs_sg" {
  name        = "flask-app-sg"
  description = "Allow HTTP traffic on port 80"
  vpc_id      = "vpc-xxxxxx" # Replace with your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define the ECS service to run the Flask app task in the ECS cluster
resource "aws_ecs_service" "flask_ecs_service" {
  name            = "flask-app-service"
  cluster         = aws_ecs_cluster.flask_app_cluster.id
  task_definition = aws_ecs_task_definition.flask_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-xxxxxx"]  # Replace with your subnet ID
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

# Optional: Output ECS cluster and service details
output "ecs_cluster_name" {
  value = aws_ecs_cluster.flask_app_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.flask_ecs_service.name
}

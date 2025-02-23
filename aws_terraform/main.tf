terraform {
  backend "s3" {
    bucket = "my-9898989-1234-secure-bucket-123456"
    key    = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

# Create a new VPC
resource "aws_vpc" "flask_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "flask-app-vpc"
  }
}

# Create public subnets in different availability zones
resource "aws_subnet" "flask_subnet_1" {
  vpc_id                  = aws_vpc.flask_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "flask-subnet-1"
  }
}

resource "aws_subnet" "flask_subnet_2" {
  vpc_id                  = aws_vpc.flask_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "flask-subnet-2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "flask_igw" {
  vpc_id = aws_vpc.flask_vpc.id

  tags = {
    Name = "flask-igw"
  }
}

# Create a route table and associate it with public subnets
resource "aws_route_table" "flask_route_table" {
  vpc_id = aws_vpc.flask_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.flask_igw.id
  }

  tags = {
    Name = "flask-route-table"
  }
}

# Associate subnets with the route table
resource "aws_route_table_association" "flask_subnet_association_1" {
  subnet_id      = aws_subnet.flask_subnet_1.id
  route_table_id = aws_route_table.flask_route_table.id
}

resource "aws_route_table_association" "flask_subnet_association_2" {
  subnet_id      = aws_subnet.flask_subnet_2.id
  route_table_id = aws_route_table.flask_route_table.id
}

# Create a Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "flask-app-sg"
  description = "Allow HTTP traffic on port 5000"
  vpc_id      = aws_vpc.flask_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
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

# Reference the existing ECR repository
data "aws_ecr_repository" "my_ecr" {
  name = "my-flask-app"
}

# Create IAM Role for ECS Task Execution
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
        Action   = "ecr:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ecs:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "logs:*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Define the ECS Cluster
resource "aws_ecs_cluster" "flask_app_cluster" {
  name = "flask-app-cluster"
}

# Define the ECS Task Definition
resource "aws_ecs_task_definition" "flask_task_definition" {
  family                   = "flask-app-task"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "flask-app-container"
    image     = "${data.aws_ecr_repository.my_ecr.repository_url}:latest"
    essential = true
    portMappings = [
      {
        containerPort = 5000
        hostPort      = 5000
        protocol      = "tcp"
      }
    ]
  }])
}

# Define the ECS Service
resource "aws_ecs_service" "flask_ecs_service" {
  name            = "flask-app-service"
  cluster         = aws_ecs_cluster.flask_app_cluster.id
  task_definition = aws_ecs_task_definition.flask_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.flask_subnet_1.id, aws_subnet.flask_subnet_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

# CloudWatch Log Group for ECS Logs
resource "aws_cloudwatch_log_group" "flask_log_group" {
  name = "/ecs/flask-app-logs"
}

# CloudWatch Metric Alarm to monitor logs
resource "aws_cloudwatch_metric_alarm" "flask_log_alarm" {
  alarm_name                = "flask-log-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "IncomingLogEvents"
  namespace                 = "AWS/Logs"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "10"
  alarm_description         = "Trigger alarm when log is written more than 10 times in a minute"
  insufficient_data_actions = []

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.flask_log_group.name
  }

  actions_enabled = true
  alarm_actions   = ["arn:aws:sns:us-east-1:058264462530:MySNS"]
}

# Outputs
output "vpc_id" {
  value = aws_vpc.flask_vpc.id
}

output "subnet_1_id" {
  value = aws_subnet.flask_subnet_1.id
}

output "subnet_2_id" {
  value = aws_subnet.flask_subnet_2.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.flask_app_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.flask_ecs_service.name
}


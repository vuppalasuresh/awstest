resource "aws_ecs_cluster" "flask_app_cluster" {
  name = "flask-app-cluster"
}

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

resource "aws_ecs_service" "flask_ecs_service" {
  name            = "flask-app-service"
  cluster         = aws_ecs_cluster.flask_app_cluster.id
  task_definition = aws_ecs_task_definition.flask_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [
      "subnet-01b120aa2483e220a",
      "subnet-0f3af6c61caf61983",
      "subnet-0ac62e963c443c7b2",
      "subnet-0fffd40e39db04651",
      "subnet-08c72b3f56e7ff52f",
      "subnet-0515a928de6d41455"
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

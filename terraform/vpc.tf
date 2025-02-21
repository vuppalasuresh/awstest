resource "aws_security_group" "ecs_sg" {
  name        = "flask-app-sg-new"
  description = "Allow HTTP traffic on port 5000"
  vpc_id      = "vpc-0461e865c5a2055c5"  # Your VPC ID

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

# Providers
provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "all_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

# Cloud Map Service Discovery Namespace
resource "aws_service_discovery_private_dns_namespace" "service_discovery" {
  name        = "example.local"
  description = "Service discovery namespace"
  vpc         = data.aws_vpc.selected.id
}

# Backend Task Definition with Python Services
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-python-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([
    {
      name      = "python-service-1"
      image     = "python:3.11-slim"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]
      command = ["python", "-m", "http.server", "5000"]
    },
    {
      name      = "python-service-2"
      image     = "python:3.11-slim"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5001
          hostPort      = 5001
          protocol      = "tcp"
        }
      ]
      command = ["python", "-m", "http.server", "5001"]
    }
  ])
}

# Backend ECS Service with Service Discovery
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.all_subnets.ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend_service.arn
  }
}

# Cloud Map Service for Backend
resource "aws_service_discovery_service" "backend_service" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.service_discovery.id
    dns_records {
      type = "A"
      ttl  = 60
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# Frontend Task Definition
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "frontend-container"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
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

# Frontend ECS Service
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.all_subnets.ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}

# Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg-"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 0
    to_port     = 65535
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

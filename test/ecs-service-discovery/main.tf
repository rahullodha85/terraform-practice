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

locals {
  fast_api_env_vars = yamldecode(file("${path.module}/fast_api_1_env_vars.yml"))
  fast_api_2_env_vars = yamldecode(file("${path.module}/fast_api_2_env_vars.yml"))
  container_fast_api_1_env_vars = jsonencode([for var_name, var_value in local.fast_api_env_vars : {
    name = var_name
    value = var_value
  }])

  container_fast_api_2_env_vars = jsonencode([for var_name, var_value in local.fast_api_2_env_vars : {
    name = var_name
    value = var_value
  }])
}

# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

# Cloud Map Service Discovery Namespace
resource "aws_service_discovery_private_dns_namespace" "service_discovery" {
  name        = "${var.app_name}.private"
  description = "Service discovery namespace"
  vpc         = data.aws_vpc.selected.id
}

resource "aws_service_discovery_public_dns_namespace" "public_service_discovery" {
  name = "${var.app_name}.public"
  description = "Public Service Discovery Namespace"
}

resource "aws_service_discovery_service" "frontend_public_service" {
  name = "frontend"
  dns_config {
    namespace_id = aws_service_discovery_public_dns_namespace.public_service_discovery.id
    dns_records {
      ttl  = 60
      type = "A"
    }
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

# cloudwatch log group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/${var.app_name}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  inline_policy {
    name = "remote-exec-policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "ssmmessages:*",
            "ssm:StartSession",
            "ecs:ExecuteCommand",
            "servicediscovery:CreateService",
            "servicediscovery:RegisterInstance",
            "servicediscovery:DiscoverInstances"
          ],
          Resource = "*"
        }
      ]
    })
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

# Backend Task Definition with Python Services
resource "aws_ecs_task_definition" "backend_task" {
  container_definitions = jsonencode([
    {
      name      = "fast-api-2"
      image = "rahullodha85/fast-api-2:latest"
      cpu       = var.cpu/2
      memory    = var.memory/2
      environment = jsondecode(local.container_fast_api_2_env_vars)
      essential = true
      portMappings = [
        {
          containerPort = 8001
          hostPort      = 8001
        }
      ]
      healthCheck = {
        command = ["CMD-SHELL", "wget -q --spider http://localhost:8001/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  cpu = var.cpu
  memory = var.memory
  family                = "${var.app_name}-backend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode          = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

# Backend ECS Service with Service Discovery
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  desired_count   = var.desired_count
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

# Frontend Task Definition
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "${var.app_name}-frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "fast-api-1"
      image = "rahullodha85/fast-api-1:latest"
      cpu       = var.cpu/2
      memory    = var.memory/2
      environment = jsondecode(local.container_fast_api_1_env_vars)
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      healthCheck = {
        command = ["CMD-SHELL", "wget -q --spider http://localhost:8000/health || exit 1"]
        interval = 30
        timeout = 5
        retries = 3
        startPeriod = 60
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region = var.region
          awslogs-stream-prefix = "ecs"
        }
      }

    },
  ])
}

# Frontend ECS Service
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.all_subnets.ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.frontend_public_service.arn
  }
}

# Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-sg-"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

variable "region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "fast-api-test" #TODO remove this
}

variable "cpu" {
  default = 512
}

variable "memory" {
  default = 1024
}


# variable "fast_api_1_env_vars" {
#   default = "fast_api_1_env_vars.yaml"
# }
#
# variable "fast_api_2_env_vars" {
#   default = "fast_api_2_env_vars.yaml"
# }

variable "desired_count" {
  default = 1
}

variable "log_retention_in_days" {
  default = 7
}

data "aws_route53_zone" "main" {
  name = "rahul-aws.com"
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.id
  name    = "backend.rahul-aws.com"
  type    = "CNAME"
  ttl     = 60

  records = ["backend.${aws_service_discovery_private_dns_namespace.service_discovery.name}"]
}


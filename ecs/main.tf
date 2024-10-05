data aws_caller_identity current {}

# cloudwatch log group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/${var.app_name}"
  retention_in_days = var.log_retention_in_days
}

# Custer
resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Task Definition
resource "aws_ecs_task_definition" "task_def" {
  container_definitions = jsonencode([
    {
      name      = "fast-api-test"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/fast-api-test:latest" #TODO parameterize image name and tag name
      cpu       = var.cpu
      memory    = var.memory
      environment = jsondecode(local.container_fast_api_env_vars)
#       essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
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
  family                = "${var.app_name}-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode          = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

#Service
resource "aws_ecs_service" "service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_def.arn
  desired_count   = 1
#   iam_role        = aws_iam_role.ecs_task_execution_role.arn
  launch_type = "FARGATE"

  network_configuration {
    subnets = data.aws_subnets.all.ids
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.ecs_tg.arn
#     container_name   = "fast-api-test"
#     container_port   = 8000   # The container's port 8000 is mapped to ALB's port 80
#   }

}

resource "aws_security_group" "ecs_service" {
  vpc_id = data.aws_vpc.selected.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
#     security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB
# resource "aws_lb" "ecs_alb" {
#   name               = "${var.app_name}-alb"
#   internal           = false  # This makes it public
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]  # Attach ALB security group
#   subnets            = data.aws_subnets.all.ids
# }
#
# resource "aws_lb_target_group" "ecs_tg" {
#   name     = "${var.app_name}-target-group"
#   port     = 80                       # ALB will listen on port 80
#   protocol = "HTTP"
#   vpc_id   = data.aws_vpc.selected.id
#   target_type = "ip"
#
#   health_check {
#     path                = "/"
#     interval            = 30
#     timeout             = 5
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     matcher             = "200"
#   }
# }

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.ecs_alb.arn
#   port              = "80"            # ALB listens on port 80
#   protocol          = "HTTP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ecs_tg.arn
#   }
# }
#
# resource "aws_security_group" "alb_sg" {
#   vpc_id = data.aws_vpc.selected.id
#
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
#   }
#
#   tags = {
#     Name = "alb-sg"
#   }
# }


# VPC Query
data "aws_vpc" "selected" {
  id = "vpc-db2130a0"
}

data aws_subnets "all" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

locals {
  fast_api_env_vars = yamldecode(file(var.fast_api_env_vars))
  container_fast_api_env_vars = jsonencode([for var_name, var_value in local.fast_api_env_vars : {
    name = var_name
    value = var_value
  }])
}

variable "app_name" {
  default = "fast-api-test" #TODO remove this
}

variable "cpu" {
  default = 256
}

variable "memory" {
  default = 512
}

variable "log_retention_in_days" {
  default = 7
}

variable "region" {
  default = "us-east-1"
}

variable "fast_api_env_vars" {}

output "test" {
  value = local.fast_api_env_vars
}
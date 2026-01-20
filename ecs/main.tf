data aws_caller_identity current {}

# # ECR private links
# resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
# #   vpc_id = data.aws_vpc.selected.id
#   vpc_id = var.vpc_id
#   service_name = "com.amazonaws.${var.region}.ecr.dkr"
#   security_group_ids = [aws_security_group.ecs_service.id]
#   vpc_endpoint_type = "Interface"
# #   subnet_ids = [data.aws_subnets.all.ids[0]]
#   subnet_ids = [var.subnet_id]
#   private_dns_enabled = true
# }
#
# resource "aws_vpc_endpoint" "ecr_api_endpoint" {
#   service_name = "com.amazonaws.us-east-1.ecr.api"
# #   vpc_id       = data.aws_vpc.selected.id
#   vpc_id = var.vpc_id
#   security_group_ids = [aws_security_group.ecs_service.id]
#   vpc_endpoint_type = "Interface"
# #   subnet_ids = [data.aws_subnets.all.ids[0]]
#   subnet_ids = [var.subnet_id]
#   private_dns_enabled = true
# }
#
# resource "aws_vpc_endpoint" "s3_endpoint" {
#   service_name = "com.amazonaws.${var.region}.s3"
# #   vpc_id       = data.aws_vpc.selected.id
#   vpc_id = var.vpc_id
# #   route_table_ids = [data.aws_vpc.selected.main_route_table_id]
#   route_table_ids = [var.route_table_id]
#   vpc_endpoint_type = "Gateway"
#   private_dns_enabled = true
# }

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
      name      = "fast-api-1"
      image = "rahullodha85/fast-api-1:latest"
#       image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/fast-api-test:latest" #TODO parameterize image name and tag name
      cpu       = var.cpu/2
      memory    = var.memory/2
      environment = jsondecode(local.container_fast_api_1_env_vars)
#       essential = true
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
    {
      name      = "fast-api-2"
      image = "rahullodha85/fast-api-2:latest"
#       image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/fast-api-test:latest" #TODO parameterize image name and tag name
      cpu       = var.cpu/2
      memory    = var.memory/2
      environment = jsondecode(local.container_fast_api_2_env_vars)
#       essential = true
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
  family                = "${var.app_name}-task-definition"
  requires_compatibilities = ["FARGATE"]
  network_mode          = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
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
            "ecs:ExecuteCommand"
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

# Service
resource "aws_ecs_service" "service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task_def.arn
  desired_count   = 1
#   iam_role        = aws_iam_role.ecs_task_execution_role.arn
  launch_type = "FARGATE"
  enable_execute_command = true
  force_new_deployment = true

  network_configuration {
    subnets = data.aws_subnets.all.ids
#     subnets = [var.subnet_id]
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fast_api_1.arn
    container_name   = "fast-api-1"
    container_port   = 8000   # The container's port 8000 is mapped to ALB's port 80
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fast_api_2.arn
    container_name = "fast-api-2"
    container_port = 8001
  }

}

resource "aws_security_group" "ecs_service" {
  vpc_id = data.aws_vpc.selected.id
#   vpc_id = var.vpc_id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
#     cidr_blocks = [data.aws_vpc.selected.cidr_block]
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
#     cidr_blocks = [data.aws_vpc.selected.cidr_block]
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB
resource "aws_lb" "ecs_alb" {
  name               = "${var.app_name}-alb"
  internal           = false  # This makes it public
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]  # Attach ALB security group
  subnets            = data.aws_subnets.all.ids
#   subnets = [var.subnet_id]
}

resource "aws_lb_target_group" "fast_api_1" {
  name     = "${var.app_name}-target-group"
  port     = 80                       # ALB will listen on port 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id
#   vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "fast_api_2" {
  name     = "${var.app_name}-target-group-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id
#   vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "80"            # ALB listens on port 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fast_api_1.arn
  }
}

resource "aws_lb_listener" "ecs_listener_2" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = "8001"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fast_api_2.arn
  }
}

# resource "aws_alb_listener_rule" "fast_api_1_rule" {
#   listener_arn = aws_lb_listener.ecs_listener.arn
#   priority     = 100
#   action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.fast_api_1.arn
#   }
#
#   condition {
#     path_pattern {
#       values = ["/fast-api-1"]
#     }
#   }
# }
#
# resource "aws_alb_listener_rule" "fast_api_2_rule" {
#   listener_arn = aws_lb_listener.ecs_listener_2.arn
#   priority     = 100
#   action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.fast_api_2.arn
#   }
#
#   condition {
#     path_pattern {
#       values = ["/fast-api-2"]
#     }
#   }
# }

resource "aws_security_group" "alb_sg" {
  vpc_id = data.aws_vpc.selected.id
#   vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from anywhere
  }

  ingress {
    from_port = 8001
    to_port = 8001
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "alb-sg"
  }
}


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
  fast_api_env_vars = yamldecode(file(var.fast_api_1_env_vars))
  fast_api_2_env_vars = yamldecode(file(var.fast_api_2_env_vars))
  container_fast_api_1_env_vars = jsonencode([for var_name, var_value in local.fast_api_env_vars : {
    name = var_name
    value = var_value
  }])

  container_fast_api_2_env_vars = jsonencode([for var_name, var_value in local.fast_api_2_env_vars : {
    name = var_name
    value = var_value
  }])
}

variable "vpc_id" {}

variable "subnet_id" {}

variable "route_table_id" {}

variable "app_name" {
  default = "fast-api-test" #TODO remove this
}

variable "cpu" {
  default = 512
}

variable "memory" {
  default = 1024
}

variable "log_retention_in_days" {
  default = 7
}

variable "region" {
  default = "us-east-1"
}

variable "fast_api_1_env_vars" {}

variable "fast_api_2_env_vars" {}

variable "image_tag" {}

output "alb" {
  value = aws_lb.ecs_alb
}
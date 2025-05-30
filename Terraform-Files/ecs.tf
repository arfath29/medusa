resource "aws_ecs_cluster" "medusa" {
  name = "medusa-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "medusa" {
  family                   = "medusa-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "medusa-container"
    image     = var.medusa_image
    essential = true
    portMappings = [{
      containerPort = var.medusa_port
      hostPort      = var.medusa_port
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "NODE_ENV",
        value = var.environment
      },
      {
        name  = "PORT",
        value = tostring(var.medusa_port)
      },
      {
        name  = "DATABASE_URL",
        value = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.medusa.endpoint}/${aws_db_instance.medusa.db_name}"
      },
      {
        name  = "REDIS_URL",
        value = "redis://${aws_elasticache_cluster.medusa.cache_nodes[0].address}:${aws_elasticache_cluster.medusa.cache_nodes[0].port}"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.medusa.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "medusa" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa.id
  task_definition = aws_ecs_task_definition.medusa.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs.id]
    subnets         = aws_subnet.private[*].id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.medusa.arn
    container_name   = "medusa-container"
    container_port   = var.medusa_port
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "medusa-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "medusa-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" # example
}
resource "aws_iam_role" "ecr_push_role" {
  name = "ecr-push-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com" # or your CI/CD service principal
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ecr_push_policy" {
  name        = "ecr-push-policy"
  description = "Policy to allow pushing Docker images to ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_push_attachment" {
  role       = aws_iam_role.ecr_push_role.name
  policy_arn = aws_iam_policy.ecr_push_policy.arn
}


resource "aws_cloudwatch_log_group" "medusa" {
  name              = "/ecs/medusa"
  retention_in_days = 30
}

# ECR Repository for Medusa
resource "aws_ecr_repository" "medusa" {
  name                 = "medusa-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # Enable vulnerability scanning
  }

  # Optional: Auto-delete untagged images to save costs
  lifecycle {
    prevent_destroy = false
  }
}

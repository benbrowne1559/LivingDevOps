// service,  cluster, task

//alb

resource "aws_ecs_cluster" "ecs-cls" {
  name = "webapp-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "ecs-service" {
  name                 = "webapp-service"
  cluster              = aws_ecs_cluster.ecs-cls.id
  task_definition      = aws_ecs_task_definition.ecs_task.arn
  desired_count        = 1
  launch_type          = "FARGATE"
  force_new_deployment = true

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets = [aws_subnet.private1-sn.id, aws_subnet.private2-sn.id]
    security_groups = [aws_security_group.ecstask-sg.id]
  }

  depends_on = [aws_lb_listener.http-listener, aws_lb_listener.https-listener]
}


resource "aws_ecs_task_definition" "ecs_task" {
  container_definitions = jsonencode([{
    environment = [{
      name  = "SECRET_NAME"
      value = module.db.db_instance_master_user_secret_arn
      },
      {
      name  = "AWS_REGION"
      value = var.region
      }, {
      name  = "DB_USER"
      value = "postgres"
    },
    {
      name  = "DB_NAME"
      value = "postgres"
    },
      {
      name  = "DB_PORT"
      value = "5432"
    },
      {
      name  = "HOST"
      value = "postgresdb.c10swucomzvi.eu-west-2.rds.amazonaws.com"
    },
    ]
    environmentFiles = []
    essential        = true
    image            = var.image_tag
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.webapp_logs.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
      secretOptions = []
    }
    mountPoints = []
    name        = var.container_name
    portMappings = [{
      appProtocol   = "http"
      containerPort = var.container_port
      hostPort      = var.container_port
      name          = "5000"
      protocol      = "tcp"
    }]
    systemControls = []
    ulimits        = []
    volumesFrom    = []
  }])
  cpu                      = "512"
  enable_fault_injection   = false
  execution_role_arn       = aws_iam_role.task_exec_role.arn
  family                   = "webapp_tsk"
  ipc_mode                 = null
  memory                   = "1024"
  network_mode             = "awsvpc"
  pid_mode                 = null
  region                   = var.region
  requires_compatibilities = ["FARGATE"]
  skip_destroy             = null
  tags                     = {}
  tags_all                 = {}
  task_role_arn            = aws_iam_role.ecs_secrets_role.arn
  track_latest             = false
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_cloudwatch_log_group" "webapp_logs" {
  name              = "/ecs/webapp"
  retention_in_days = 1
}

// task execution role and secrets manager read role

resource "aws_iam_role_policy_attachment" "secrets_read_only_pol" {
  role       = aws_iam_role.ecs_secrets_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSSecretsManagerClientReadOnlyAccess"

  depends_on = [aws_iam_role.ecs_secrets_role]
}

resource "aws_iam_role" "ecs_secrets_role" {
  name = "ecs-secrets-read-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com" # Change this if using EC2, Lambda, etc.
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_exec_pol" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

  depends_on = [aws_iam_role.task_exec_role]
}

resource "aws_iam_role_policy" "task_exec_logs_policy" {
  name = "task_exec_logs_policy"
  role = aws_iam_role.task_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.webapp_logs.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role" "task_exec_role" {
  name = "task_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com" # Change this if using EC2, Lambda, etc.
        }
      }
    ]
  })
}

data "aws_caller_identity" "account" {}
data "aws_region" "region" {}

locals {
  account_id = data.aws_caller_identity.account.account_id
  region     = data.aws_region.region.name

  route53_name = "${var.ecs.name}.${var.ecs.zone_name}"

  image_url = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.ecs.image_name}"
}

resource "aws_ecr_repository" "main" {
  name = var.ecs.image_name
  tags = var.ecs.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.ecs.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs.cpu
  memory                   = var.ecs.memory
  execution_role_arn       = var.ecs.execution_role_arn
  task_role_arn            = var.ecs.task_role_arn

  container_definitions = jsonencode([
    {
      name        = var.ecs.name
      image       = local.image_url
      essential   = true
      networkMode = "awsvpc"
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          Name           = "datadog"
          apikey         = "REPLACE_ME_API_KEY"
          Host           = "http-intake.logs.datadoghq.com"
          TLS            = "on"
          dd_service     = var.ecs.dd_service
          dd_source      = var.ecs.dd_source
          dd_message_key = "log"
          dd_tags        = "project:${var.ecs.dd_project}, env:${var.ecs.dd_env}"
          provider       = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = var.ecs.container_port
        }
      ]
      dockerLabels : {
        "com.datadoghq.tags.env" : var.ecs.dd_env,
        "com.datadoghq.tags.service" : var.ecs.name,
        "com.datadoghq.ad.instances" : "[{\"host\": \"%%host%%\", \"port\": ${var.ecs.container_port}}]",
        "com.datadoghq.ad.check_names" : "[\"${var.ecs.name}\"]",
        "com.datadoghq.ad.init_configs" : "[{}]"
      }
    }
    , {
      name      = "log_router"
      image     = var.ecs.fluentbit_image_url
      essential = false
      firelensConfiguration = {
        type = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
        }
      }
      dockerLabels : {
        "com.datadoghq.tags.env" : var.ecs.dd_env,
        "com.datadoghq.tags.service" : var.ecs.name,
      }
    },
    {
      name      = "datadog-agent"
      image     = "public.ecr.aws/datadog/agent:latest"
      essential = false
      environment = [
        {
          name  = "DD_API_KEY"
          value = "REPLACE_ME_DD_API_KEY"
        },
        {
          name  = "DD_VERSION"
          value = "2022.01.27"
        },
        {
          name  = "DD_ENV"
          value = var.ecs.dd_env
        },
        {
          name  = "DD_SERVICE"
          value = var.ecs.name
        },
        {
          name  = "ECS_FARGATE"
          value = "true"
        },
        {
          name  = "DD_APM_ENABLED"
          value = "true"
        }
      ]
      dockerLabels : {
        "com.datadoghq.tags.env" : var.ecs.dd_env,
        "com.datadoghq.tags.service" : var.ecs.name,
      }
    }
  ])
  tags = var.ecs.tags
}

resource "aws_ecs_service" "main" {
  name    = var.ecs.name
  cluster = var.ecs.cluster

  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.ecs.desired_count
  launch_type     = "FARGATE"

  enable_execute_command = true

  health_check_grace_period_seconds  = 60
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    security_groups = [aws_security_group.main.id]
    subnets         = var.ecs.private_subnets
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = var.ecs.name
    container_port   = var.ecs.container_port
  }

  tags = var.ecs.tags
}

resource "aws_alb" "main" {
  name            = var.ecs.name
  subnets         = var.ecs.public_subnets
  security_groups = [aws_security_group.main.id]
}

resource "aws_alb_target_group" "main" {
  name        = var.ecs.name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.ecs.vpc_id
  target_type = "ip"
  health_check {
    enabled             = "true"
    interval            = "30"
    matcher             = "200-299"
    path                = var.ecs.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
    healthy_threshold   = "5"
    unhealthy_threshold = "5"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.ecs.tags
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }
}

resource "aws_security_group" "main" {
  name_prefix = var.ecs.name
  vpc_id      = var.ecs.vpc_id
  ingress {
    protocol    = "tcp"
    from_port   = var.ecs.container_port
    to_port     = var.ecs.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "udp"
    from_port   = 8125
    to_port     = 8125
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8126
    to_port     = 8126
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.ecs.tags
}

resource "aws_route53_record" "internal" {
  zone_id = var.ecs.zone_id
  name    = local.route53_name
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = "false"
  }
}

data "aws_caller_identity" "account" {}
data "aws_region" "region" {}

locals {
  account_id = data.aws_caller_identity.account.account_id
  region     = data.aws_region.region.name

  image_url = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.image_name}"

  route53_name = "${var.container_name}.${var.zone_name}"
}

resource "aws_ecr_repository" "main" {
  name = var.image_name
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name        = var.container_name
      image       = var.image_url
      essential   = true
      networkMode = "awsvpc"
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          Name           = "datadog"
          apikey         = var.dd_api_key
          Host           = "http-intake.logs.datadoghq.com"
          TLS            = "on"
          dd_service     = var.dd_service
          dd_source      = var.dd_source
          dd_message_key = "log"
          dd_tags        = "project:${var.dd_project}, env:${var.dd_env}"
          provider       = "ecs"
        }
      }
      portMappings = [
        {
          containerPort = var.container_port
        },
        {
          containerPort = 15672
        }

      ]
      dockerLabels : {
        "com.datadoghq.tags.env" : var.dd_env,
        "com.datadoghq.tags.service" : var.container_name,
        "com.datadoghq.ad.instances" : "[{\"host\": \"%%host%%\", \"port\": ${var.container_port}}]",
        "com.datadoghq.ad.check_names" : "[\"${var.container_name}\"]",
        "com.datadoghq.ad.init_configs" : "[{}]"
      }
    }
    , {
      name      = "log_router"
      image     = var.fluentbit_image_url
      essential = false
      firelensConfiguration = {
        type = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
        }
      }
      dockerLabels : {
        "com.datadoghq.tags.env" : var.dd_env,
        "com.datadoghq.tags.service" : var.container_name,
      }
    },
    {
      name      = "datadog-agent"
      image     = "public.ecr.aws/datadog/agent:latest"
      essential = false
      environment = [
        {
          name  = "DD_API_KEY"
          value = var.dd_api_key
        },
        {
          name  = "DD_VERSION"
          value = "2022.01.27"
        },
        {
          name  = "DD_ENV"
          value = var.dd_env
        },
        {
          name  = "DD_SERVICE"
          value = var.container_name
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
        "com.datadoghq.tags.env" : var.dd_env,
        "com.datadoghq.tags.service" : var.container_name,
      }
    }
  ])
  tags = var.tags
}

resource "aws_ecs_service" "main" {
  name    = var.container_name
  cluster = var.cluster

  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  enable_execute_command = true

  health_check_grace_period_seconds  = 120
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    security_groups  = [aws_security_group.service.id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.taget_group_rabbit
    container_name   = var.container_name
    container_port   = 5672
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.management.arn
    container_name   = var.container_name
    container_port   = 15672
  }

  tags = var.tags
}

#nlb
resource "aws_lb" "network" {
  name               = "${var.container_name}-network-lb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnets

  enable_deletion_protection = true

  tags = var.tags
}
# stickiness가 테라폼 오류로 먹히지가 않음
#resource "aws_lb_target_group" "rabbit" {
#  name        = var.container_name
#  port        = 5672
#  protocol    = "TCP"
#  vpc_id      = var.vpc_id
#  target_type = "ip"
#
#  lifecycle {
#    create_before_destroy = true
#  }
#
#  stickiness {
#    type    = "lb_cookie"
#    enabled = false
#  }
#
#  tags = var.tags
#}
#
#resource "aws_lb_listener" "rabbit" {
#  load_balancer_arn = aws_lb.network.arn
#  port              = 5672
#  protocol          = "TCP"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.rabbit.arn
#  }
#}

#alb
resource "aws_alb" "main" {
  name            = var.container_name
  subnets         = var.public_subnets
  security_groups = [aws_security_group.main.id]
}

resource "aws_alb_target_group" "management" {
  name        = "admin-${var.container_name}"
  port        = 15672
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    enabled             = "true"
    healthy_threshold   = "5"
    interval            = "40"
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = 15672
    protocol            = "HTTP"
    timeout             = "30"
    unhealthy_threshold = "2"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags

}

resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port              = "15672"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.management.arn
  }
}



resource "aws_security_group" "service" {
  name_prefix = "service-${var.container_name}"
  vpc_id      = var.vpc_id
  ingress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "udp"
    from_port   = 5672
    to_port     = 5672
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 15672
    to_port     = 15672
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_security_group" "main" {
  name_prefix = var.container_name
  vpc_id      = var.vpc_id
  ingress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 15672
    to_port     = 15672
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

  tags = var.tags
}

resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = local.route53_name
  type    = "A"

  alias {
    name                   = aws_alb.main.dns_name
    zone_id                = aws_alb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "internal" {
  zone_id = var.zone_id
  name    = var.internal_route53_name
  type    = "A"
  alias {
    name                   = aws_lb.network.dns_name
    zone_id                = aws_lb.network.zone_id
    evaluate_target_health = true
  }
}

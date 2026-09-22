## acmemall backend
resource "aws_ecs_task_definition" "backend_mall" {
  family                   = var.mall.backend.task_definition_name
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.mall.backend.task_role_arn
  execution_role_arn       = var.mall.backend.execution_role_arn

  network_mode = "awsvpc"
  cpu          = 1024
  memory       = 4096

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.mall.common.project
    Component   = var.mall.backend.dd_service
  }

  volume {
    name = "static-storage"
  }
  volume {
    name = "media-storage"
  }

  container_definitions = jsonencode(flatten([
    [
      merge(var.dd_config_logs.default, local.mall_backend_dd_docker_labels)
    ],
    [
      merge(var.dd_config_metrics.default, local.mall_backend_dd_docker_labels, {
        environment : local.mall_backend_dd_container_env
      })
    ],
    [
      {
        name  = "app"
        image = var.mall.backend.container_info.app_image
        linuxParameters = {
          initProcessEnabled = true
        }
        portMappings = var.mall.backend.container_info.app_ports
        dockerLabels = merge(var.mall.backend.container_info.app_dd_labels, {
          "com.datadoghq.tags.project" = var.mall.common.project,
          "com.datadoghq.tags.env"     = var.env
        })
        environment = [for k, v in var.mall.backend.container_info.app_env : { name = k, value = v }]
        command     = ["/bin/bash", "-c", "python manage.py create_server_config && python manage.py collectstatic --noinput && gunicorn acme.wsgi:application --bind 0.0.0.0:8000 --max-requests 1000 --max-requests-jitter 50 --workers=5 --timeout 120 --access-logfile - --error-logfile - "],

        cpu         = 0
        essential   = true
        volumesFrom = []

        mountPoints = [
          {
            sourceVolume  = "static-storage"
            containerPath = "/acme-backend/acme/static"
            readOnly      = false
          },
          {
            sourceVolume  = "media-storage"
            containerPath = "/acme-backend/acme/media"
            readOnly      = false
          }
        ]

        logConfiguration = {
          logDriver     = "awsfirelens"
          secretOptions = null
          options = {
            dd_message_key = "log"
            apikey         = var.dd_config.api_key
            provider       = "ecs"
            dd_service     = var.mall.backend.dd_service
            Host           = "http-intake.logs.datadoghq.com"
            TLS            = "on"
            dd_source      = "django"
            dd_tags        = "project:${var.mall.common.project},env:${var.env}"
            Name           = "datadog"
          }
        },
      },
      {
        name  = "nginx"
        image = var.mall.backend.container_info.nginx_image
        portMappings = [
          {
            containerPort = 80
            hostPort      = 80
          }
        ],
        linuxParameters = {
          initProcessEnabled = true
        }
        command = ["nginx", "-g", "daemon off;"]

        cpu         = 0
        environment = []
        essential   = true
        mountPoints = []
        volumesFrom = []

        logConfiguration = {
          logDriver     = "awsfirelens"
          secretOptions = null
          options = {
            dd_message_key = "log"
            apikey         = var.dd_config.api_key
            provider       = "ecs"
            dd_service     = var.mall.backend.dd_service
            Host           = "http-intake.logs.datadoghq.com"
            TLS            = "on"
            dd_source      = "nginx"
            dd_tags        = "project:${var.mall.common.project},env:${var.env}"
            Name           = "datadog"
          }
        },
      },
  ]]))
}

resource "aws_ecs_service" "backend_mall" {
  name                   = var.mall.backend.ecs_service_name
  cluster                = var.mall.common.cluster_name
  task_definition        = aws_ecs_task_definition.backend_mall.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  load_balancer {
    target_group_arn = data.terraform_remote_state.infra_common_alb.outputs.backend_target_group_arns[1]
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
    security_groups = [data.aws_security_group.backend_mall.id]
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.mall.common.project
    Component   = var.mall.backend.dd_service
  }
}

## partner backend
resource "aws_ecs_task_definition" "backend_partner" {
  family                   = var.partner.backend.task_definition_name
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.partner.backend.task_role_arn
  execution_role_arn       = var.partner.backend.execution_role_arn

  network_mode = "awsvpc"
  cpu          = 2048
  memory       = 4096

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.partner.common.project
    Component   = var.partner.backend.dd_service
  }

  container_definitions = jsonencode(flatten([
    [
      merge(var.dd_config_logs.default, local.partner_backend_dd_docker_labels)
    ],
    [
      merge(var.dd_config_metrics.default, local.partner_backend_dd_docker_labels, {
        environment : local.partner_backend_dd_container_env
      })
    ],
    [
      {
        name         = "app"
        image        = var.partner.backend.container_info.app_image
        portMappings = var.partner.backend.container_info.app_ports
        linuxParameters = {
          initProcessEnabled = true
        }
        dockerLabels = merge(var.partner.backend.container_info.app_dd_labels, {
          "com.datadoghq.tags.project" = var.partner.common.project,
          "com.datadoghq.tags.env"     = var.env
        })

        cpu         = 0
        environment = []
        essential   = true
        mountPoints = []
        volumesFrom = []

        logConfiguration = {
          logDriver     = "awsfirelens"
          secretOptions = null
          options = {
            dd_message_key = "log"
            apikey         = var.dd_config.api_key
            provider       = "ecs"
            dd_service     = var.partner.backend.dd_service
            Host           = "http-intake.logs.datadoghq.com"
            TLS            = "on"
            dd_source      = "spring-gateway"
            dd_tags        = "project:${var.partner.common.project},env:${var.env}"
            Name           = "datadog"
          }
        },
      },
      {
        name  = "eureka"
        image = var.partner.backend.container_info.eureka_image
        portMappings = [
          {
            containerPort = 8761
            hostPort      = 8761
          }
        ]
        linuxParameters = {
          initProcessEnabled = true
        }
        dockerLabels = merge(var.partner.backend.container_info.app_dd_labels, {
          "com.datadoghq.tags.project" = var.partner.common.project,
          "com.datadoghq.tags.env"     = var.env
        })

        logConfiguration = {
          logDriver     = "awsfirelens"
          secretOptions = null
          options = {
            dd_message_key = "log"
            apikey         = var.dd_config.api_key
            provider       = "ecs"
            dd_service     = var.partner.backend.dd_service
            Host           = "http-intake.logs.datadoghq.com"
            TLS            = "on"
            dd_source      = "eureka"
            dd_tags        = "project:${var.partner.common.project},env:${var.env}"
            Name           = "datadog"
          }
        },
      },
      {
        name  = "nginx"
        image = var.partner.backend.container_info.nginx_image
        portMappings = [
          {
            containerPort = 80
            hostPort      = 80
          }
        ],
        linuxParameters = {
          initProcessEnabled = true
        }
        command = ["nginx", "-g", "daemon off;"]

        logConfiguration = {
          logDriver     = "awsfirelens"
          secretOptions = null
          options = {
            dd_message_key = "log"
            apikey         = var.dd_config.api_key
            provider       = "ecs"
            dd_service     = var.partner.backend.dd_service
            Host           = "http-intake.logs.datadoghq.com"
            TLS            = "on"
            dd_source      = "nginx"
            dd_tags        = "project:${var.partner.common.project},env:${var.env}"
            Name           = "datadog"
          }
        },
      },
  ]]))
}

resource "aws_ecs_service" "backend_partner" {
  name                   = var.partner.backend.ecs_service_name
  cluster                = var.partner.common.cluster_name
  task_definition        = aws_ecs_task_definition.backend_partner.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  load_balancer {
    target_group_arn = data.terraform_remote_state.infra_common_alb.outputs.backend_target_group_arns[0]
    container_name   = "nginx"
    container_port   = 80
  }

  load_balancer {
    target_group_arn = data.terraform_remote_state.infra_common_alb.outputs.gateway_target_group_arn
    container_name   = "app"
    container_port   = 8088
  }

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
    security_groups = [data.aws_security_group.backend_partner.id]
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.partner.common.project
    Component   = var.partner.backend.dd_service
  }
}

## beacon backend
resource "aws_ecs_task_definition" "backend_beacon" {
  family                   = var.beacon.backend.task_definition_name
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.beacon.backend.task_role_arn
  execution_role_arn       = var.beacon.backend.execution_role_arn

  network_mode = "awsvpc"
  cpu          = 512
  memory       = 1024

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.beacon.common.project
    Component   = var.beacon.backend.dd_service
  }

  container_definitions = jsonencode(flatten([
    [
      merge(var.dd_config_logs.default, local.beacon_backend_dd_docker_labels)
    ],
    [
      merge(var.dd_config_metrics.default, local.beacon_backend_dd_docker_labels, {
        environment : local.beacon_backend_dd_container_env
      })
    ],
    [
      {
        name         = "app"
        image        = var.beacon.backend.container_info.app_image
        portMappings = var.beacon.backend.container_info.app_ports
        linuxParameters = {
          initProcessEnabled = true
        }
        dockerLabels = merge(var.beacon.backend.container_info.app_dd_labels, {
          "com.datadoghq.tags.project" = var.beacon.common.project,
          "com.datadoghq.tags.env"     = var.env
        })

        cpu         = 0
        environment = []
        essential   = true
        mountPoints = []
        volumesFrom = []

        logConfiguration = {
          logDriver     = "awsfirelens"
          secretOptions = null
          options = {
            dd_message_key = "log"
            apikey         = var.dd_config.api_key
            provider       = "ecs"
            dd_service     = var.beacon.backend.dd_service
            Host           = "http-intake.logs.datadoghq.com"
            TLS            = "on"
            dd_source      = "python"
            dd_tags        = "project:${var.beacon.common.project},env:${var.env}"
            Name           = "datadog"
          }
        },
      },
  ]]))
}

resource "aws_ecs_service" "backend_beacon" {
  name                   = var.beacon.backend.ecs_service_name
  cluster                = var.beacon.common.cluster_name
  task_definition        = aws_ecs_task_definition.backend_beacon.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  load_balancer {
    target_group_arn = data.terraform_remote_state.infra_common_alb.outputs.backend_target_group_arns[2]
    container_name   = "app"
    container_port   = 80
  }

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
    security_groups = [data.aws_security_group.backend_beacon.id]
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.beacon.common.project
    Component   = var.beacon.backend.dd_service
  }
}

## acmemall frontend
resource "aws_ecs_task_definition" "frontend_mall" {
  family                   = var.mall.frontend.task_definition_name
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.mall.frontend.task_role_arn
  execution_role_arn       = var.mall.frontend.execution_role_arn

  network_mode = "awsvpc"
  cpu          = 1024
  memory       = 4096

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.mall.common.project
    Component   = var.mall.frontend.dd_service
  }

  container_definitions = jsonencode(flatten([
    [
      merge(var.dd_config_logs.default, local.mall_frontend_dd_docker_labels)
    ],
    [
      merge(var.dd_config_metrics.default, local.mall_frontend_dd_docker_labels, {
        environment : local.mall_frontend_dd_container_env
      })
    ],
    [
      {
        name         = "app"
        image        = var.mall.frontend.container_info.app_image
        portMappings = var.mall.frontend.container_info.app_ports
        linuxParameters = {
          initProcessEnabled = true
        }
        dockerLabels = merge(var.mall.frontend.container_info.app_dd_labels, {
          "com.datadoghq.tags.project" = var.mall.common.project,
          "com.datadoghq.tags.env"     = var.env
        })
        command = ["pm2-runtime", "start", "npm", "--", "start"],

        cpu         = 0
        environment = [for k, v in var.mall.frontend.container_info.app_env : { name = k, value = v }]
        essential   = true
        mountPoints = []
        volumesFrom = []

        /* logConfiguration = { */
        /*   logDriver     = "awslogs" */
        /*   secretOptions = null */
        /*   options = { */
        /*     awslogs-group         = "acme/alpha/front/app" */
        /*     awslogs-region        = "ap-northeast-2" */
        /*     awslogs-stream-prefix = "acmemall" */
        /*   } */
        /* }, */
        logConfiguration = {
          logDriver     = "awsfirelens"
          secretOptions = null
          options = {
            dd_message_key = "log"
            apikey         = var.dd_config.api_key
            provider       = "ecs"
            dd_service     = var.mall.frontend.dd_service
            Host           = "http-intake.logs.datadoghq.com"
            TLS            = "on"
            dd_source      = "nodejs"
            dd_tags        = "project:${var.mall.common.project},env:${var.env}"
            Name           = "datadog"
          }
        },
      },
      {
        name  = "nginx"
        image = var.mall.frontend.container_info.nginx_image
        portMappings = [
          {
            protocol      = "tcp"
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
            dd_service     = var.mall.frontend.dd_service
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

resource "aws_ecs_service" "frontend_mall" {
  name                   = var.mall.frontend.ecs_service_name
  cluster                = var.mall.common.cluster_name
  task_definition        = aws_ecs_task_definition.frontend_mall.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  load_balancer {
    target_group_arn = data.terraform_remote_state.infra_common_alb.outputs.frontend_target_group_arns[0]
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
    security_groups = [data.aws_security_group.frontend_mall.id]
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.mall.common.project
    Component   = var.mall.frontend.dd_service
  }
}

## partner frontend
resource "aws_ecs_task_definition" "frontend_partner" {
  family                   = var.partner.frontend.task_definition_name
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = var.partner.frontend.task_role_arn
  execution_role_arn       = var.partner.frontend.execution_role_arn

  network_mode = "awsvpc"
  cpu          = 512
  memory       = 1024

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.partner.common.project
    Component   = var.partner.frontend.dd_service
  }

  container_definitions = jsonencode(flatten([
    [
      merge(var.dd_config_logs.default, local.partner_frontend_dd_docker_labels)
    ],
    [
      merge(var.dd_config_metrics.default, local.partner_frontend_dd_docker_labels, {
        environment : local.partner_frontend_dd_container_env
      })
    ],
    [
      {
        name         = "app"
        image        = var.partner.frontend.container_info.app_image
        portMappings = var.partner.frontend.container_info.app_ports
        linuxParameters = {
          initProcessEnabled = true
        }
        dockerLabels = merge(var.partner.frontend.container_info.app_dd_labels, {
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
            dd_service     = var.partner.frontend.dd_service
            Host           = "http-intake.logs.datadoghq.com"
            TLS            = "on"
            dd_source      = "java"
            dd_tags        = "project:${var.partner.common.project},env:${var.env}"
            Name           = "datadog"
          }
        },
      },
  ]]))
}

resource "aws_ecs_service" "frontend_partner" {
  name                   = var.partner.frontend.ecs_service_name
  cluster                = var.partner.common.cluster_name
  task_definition        = aws_ecs_task_definition.frontend_partner.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  load_balancer {
    target_group_arn = data.terraform_remote_state.infra_common_alb.outputs.frontend_target_group_arns[1]
    container_name   = "app"
    container_port   = 7001
  }

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
    security_groups = [data.aws_security_group.frontend_partner.id]
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = var.partner.common.project
    Component   = var.partner.frontend.dd_service
  }
}

### beacon frontend
#resource "aws_ecs_task_definition" "frontend_beacon" {
#  family                   = var.beacon.frontend.task_definition_name
#  requires_compatibilities = ["FARGATE"]
#  task_role_arn            = var.beacon.frontend.task_role_arn
#  execution_role_arn       = var.beacon.frontend.execution_role_arn
#
#  network_mode = "awsvpc"
#  cpu          = 4096
#  memory       = 8192
#
#  tags = {
#    Environment = var.env
#    Terraform   = "true"
#    Project     = var.beacon.common.project
#    Component   = var.beacon.frontend.dd_service
#  }
#
#  container_definitions = jsonencode(flatten([
#    [
#      merge(var.dd_config_logs.default, local.beacon_frontend_dd_docker_labels)
#    ],
#    [
#      merge(var.dd_config_metrics.default, local.beacon_frontend_dd_docker_labels, {
#        environment : local.beacon_frontend_dd_container_env
#      })
#    ],
#    [
#      {
#        name         = "app"
#        image        = var.beacon.frontend.container_info.app_image
#        portMappings = var.beacon.frontend.container_info.app_ports
#        linuxParameters = {
#          initProcessEnabled = true
#        }
#        dockerLabels = merge(var.beacon.frontend.container_info.app_dd_labels, {
#          "com.datadoghq.tags.project" = var.beacon.common.project,
#          "com.datadoghq.tags.env"     = var.env
#        })
#        logConfiguration = {
#          logDriver     = "awsfirelens"
#          secretOptions = null
#          options = {
#            dd_message_key = "log"
#            apikey         = var.dd_config.api_key
#            provider       = "ecs"
#            dd_service     = var.beacon.frontend.dd_service
#            Host           = "http-intake.logs.datadoghq.com"
#            TLS            = "on"
#            dd_source      = "java"
#            dd_tags        = "project:${var.beacon.common.project},env:${var.env}"
#            Name           = "datadog"
#          }
#        },
#      },
#      {
#        name  = "nginx"
#        image = var.beacon.frontend.container_info.nginx_image
#        portMappings = [
#          {
#            protocol      = "tcp"
#            containerPort = 80
#            hostPort      = 80
#          }
#        ],
#        linuxParameters = {
#          initProcessEnabled = true
#        }
#        command = ["nginx", "-g", "daemon off;"]
#
#        cpu         = 0
#        environment = []
#        essential   = true
#        mountPoints = []
#        volumesFrom = []
#
#        logConfiguration = {
#          logDriver     = "awsfirelens"
#          secretOptions = null
#          options = {
#            dd_message_key = "log"
#            apikey         = var.dd_config.api_key
#            provider       = "ecs"
#            dd_service     = var.beacon.frontend.dd_service
#            Host           = "http-intake.logs.datadoghq.com"
#            TLS            = "on"
#            dd_source      = "nginx"
#            dd_tags        = "project:${var.beacon.common.project},env:${var.env}"
#            Name           = "datadog"
#          }
#        },
#      }
#  ]]))
#}
#
#resource "aws_ecs_service" "frontend_beacon" {
#  name                   = var.beacon.frontend.ecs_service_name
#  cluster                = var.beacon.common.cluster_name
#  task_definition        = aws_ecs_task_definition.frontend_beacon.arn
#  desired_count          = 1
#  launch_type            = "FARGATE"
#  enable_execute_command = true
#
#  load_balancer {
#    target_group_arn = data.terraform_remote_state.infra_common_alb.outputs.frontend_target_group_arns[2]
#    container_name   = "nginx"
#    container_port   = 80
#  }
#
#  network_configuration {
#    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
#    security_groups = [data.aws_security_group.frontend_beacon.id]
#  }
#
#  tags = {
#    Environment = var.env
#    Terraform   = "true"
#    Project     = var.beacon.common.project
#    Component   = var.beacon.frontend.dd_service
#  }
#}

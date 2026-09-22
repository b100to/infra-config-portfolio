mall = {
  frontend = {
    dd_service         = "mall-frontend"
    task_role_arn      = "arn:aws:iam::222222222222:role/acmeFrontendEcsTaskRole"
    execution_role_arn = "arn:aws:iam::222222222222:role/ecsTaskExecutionRole"

    container_info = {
      app_image = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/acme/stage/mall-frontend-app:latest"
      app_ports = [
        {
          protocol      = "tcp"
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      app_env = {
        "GENERATE_SOURCEMAP" = "false"
      }
      app_dd_labels = {}
      nginx_image   = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/acme/stage/mall-frontend-nginx:latest"
    }
    task_definition_name = "am-frontend-stage"
    ecs_service_name     = "am-frontend-stage-1_2"
  }

  backend = {
    dd_service         = "mall-backend"
    task_role_arn      = "arn:aws:iam::222222222222:role/acmeBackendEcsTaskRole"
    execution_role_arn = "arn:aws:iam::222222222222:role/ecsTaskExecutionRole"

    container_info = {
      app_image = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/acme/stage/mall-backend-app:latest"
      app_ports = [
        {
          protocol      = "tcp"
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      app_env = {
        "AWS_DEFAULT_REGION"     = "ap-northeast-2"
        "DJANGO_SETTINGS_MODULE" = "acme.settings.staging"
        "ACME_ENV"             = "staging"
        "CELERY_BROKER_URL"      = "redis://acmemall-staging.abcdef.ng.0001.apn2.cache.amazonaws.com:6379/1"
        "REDIS_CACHE_URL"        = "redis://acmemall-staging-cache.abcdef.ng.0001.apn2.cache.amazonaws.com:6379/0"
      }
      app_dd_labels = {}
      nginx_image   = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/acme/stage/mall-backend-nginx:latest"
    }
    task_definition_name = "am-backend-stage"
    ecs_service_name     = "am-backend-stage-1_2"
  }

  common = {
    cluster_name = "acmemall-staging"
    project      = "mall"
  }
}

partner = {
  frontend = {
    dd_service         = "partner-frontend"
    task_role_arn      = "arn:aws:iam::222222222222:role/CloudEcsTaskRole"
    execution_role_arn = "arn:aws:iam::222222222222:role/CloudEcsTaskExecutionRole"

    container_info = {
      app_image = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/partner/front/stage:latest"
      app_ports = [
        {
          protocol      = "tcp"
          containerPort = 7001
          hostPort      = 7001
        }
      ]
      app_dd_labels = {
        "com.datadoghq.ad.instances"    = "[{\"host\": \"%%host%%\", \"port\": 7001}]"
        "com.datadoghq.ad.check_names"  = "[\"app\"]"
        "com.datadoghq.ad.init_configs" = "[{}]"
      }
      nginx_image = ""
    }
    task_definition_name = "partner-frontend-stage"
    ecs_service_name     = "partner-frontend-stage-1_2"
  }

  backend = {
    dd_service         = "spring-gateway"
    task_role_arn      = "arn:aws:iam::222222222222:role/CloudEcsTaskRole"
    execution_role_arn = "arn:aws:iam::222222222222:role/CloudEcsTaskExecutionRole"

    container_info = {
      app_image = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/gateway/stage"
      app_ports = [
        {
          protocol      = "tcp"
          containerPort = 8088
          hostPort      = 8088
        }
      ]
      app_dd_labels = {
        "com.datadoghq.ad.instances"    = "[{\"host\": \"%%host%%\", \"port\": 8088}]"
        "com.datadoghq.ad.check_names"  = "[\"app\"]"
        "com.datadoghq.ad.init_configs" = "[{}]"
      }
      nginx_image  = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/acme/stage/spring-gateway-nginx"
      eureka_image = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/eureka/stage:latest"
    }
    task_definition_name = "partner-gateway-stage"
    ecs_service_name     = "partner-gateway-stage-1_2"
  }

  common = {
    cluster_name = "acme-cloud-stage"
    project      = "partner"
  }
}

beacon = {
  frontend = {
    dd_service         = "beacon-frontend"
    task_role_arn      = "arn:aws:iam::222222222222:role/CloudEcsTaskRole"
    execution_role_arn = "arn:aws:iam::222222222222:role/CloudEcsTaskExecutionRole"

    container_info = {
      app_image = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/beacon/stage:latest"
      app_ports = [
        {
          protocol      = "tcp"
          containerPort = 8879
          hostPort      = 8879
        }
      ]
      app_dd_labels = {}
      nginx_image   = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/acme/stage/beacon-frontend-nginx:latest"
    }
    task_definition_name = "beacon-frontend-stage"
    ecs_service_name     = "beacon-stage-1_2"
  }

  backend = {
    dd_service         = "beacon-scan"
    task_role_arn      = "arn:aws:iam::222222222222:role/CloudEcsTaskRole"
    execution_role_arn = "arn:aws:iam::222222222222:role/CloudEcsTaskExecutionRole"

    container_info = {
      app_image = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/beacon/scan/stage:latest"
      app_ports = [
        {
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }
      ]
      app_dd_labels = {
        "com.datadoghq.ad.instances"    = "[{\"host\": \"%%host%%\", \"port\": 80}]"
        "com.datadoghq.ad.check_names"  = "[\"app\"]"
        "com.datadoghq.ad.init_configs" = "[{}]"
      }
    }
    task_definition_name = "beacon-scan-stage"
    ecs_service_name     = "beacon-scan-stage-1_2"
  }

  common = {
    cluster_name = "acme-cloud-stage"
    project      = "beacon"
  }
}

dd_config = {
  api_key = "REPLACE_ME_API_KEY"
}

dd_config_logs = {
  default = {
    name  = "log_router"
    image = "public.ecr.aws/aws-observability/aws-for-fluent-bit:2.23.1"
    firelensConfiguration = {
      type = "fluentbit"
      options = {
        enable-ecs-log-metadata = "true"
        config-file-type        = "file"
        config-file-value       = "/fluent-bit/configs/parse-json.conf"
      }
    }

    cpu          = 0
    environment  = []
    essential    = true
    mountPoints  = []
    volumesFrom  = []
    portMappings = []
    user         = "0"
  }
}

dd_config_metrics = {
  default = {
    name  = "datadog-agent"
    image = "public.ecr.aws/datadog/agent:7.34.0"
    portMappings = [
      {
        protocol      = "tcp"
        containerPort = 8126
        hostPort      = 8126
      }
    ],
    environments = {
      "DD_DOGSTATSD_PORT" = "8125"
      "DD_SITE"           = "datadoghq.com"
      "ECS_FARGATE"       = "true"
    }

    cpu         = 0
    environment = []
    essential   = true
    mountPoints = []
    volumesFrom = []
  }
}

mall = {
  frontend = {
    dd_service         = "mall-frontend"
    task_role_arn      = "arn:aws:iam::111111111111:role/acmeFrontendEcsTaskRole"
    execution_role_arn = "arn:aws:iam::111111111111:role/ecsTaskExecutionRole"

    container_info = {
      app_image = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/am-front-ecs/app/alpha:latest"
      app_ports = [
        {
          protocol      = "tcp"
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      app_dd_labels = {}
      nginx_image   = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/am-frontend-ecs/nginx:latest"
    }
    task_definition_name = "am-frontend-alpha"
    ecs_service_name     = "am-frontend-alpha"
  }

  backend = {
    dd_service         = "mall-backend"
    task_role_arn      = "arn:aws:iam::111111111111:role/acmeBackendEcsTaskRole"
    execution_role_arn = "arn:aws:iam::111111111111:role/ecsTaskExecutionRole"

    container_info = {
      app_image = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/am-backend-ecs/app/alpha:latest"
      app_ports = [
        {
          protocol      = "tcp"
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      app_env = {
        "AWS_DEFAULT_REGION"     = "ap-northeast-2"
        "CELERY_BROKER_URL"      = "redis://acmemall-alpha-redis.ghijkl.ng.0001.apn2.cache.amazonaws.com:6379/1"
        "DJANGO_SETTINGS_MODULE" = "acme.settings.alpha"
        "ACME_ENV"             = "alpha"
        "REDIS_CACHE_URL"        = "redis://acmemall-alpha-cache-redis.ghijkl.ng.0001.apn2.cache.amazonaws.com:6379/0"
      }
      app_dd_labels = {}
      nginx_image   = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/am-backend-ecs/nginx:latest"
    }
    task_definition_name = "am-backend-alpha"
    ecs_service_name     = "am-backend-alpha"
  }

  common = {
    cluster_name = "acmemall-alpha"
    project      = "mall"
  }
}

partner = {
  frontend = {
    dd_service         = "partner-frontend"
    task_role_arn      = "arn:aws:iam::111111111111:role/CloudEcsTaskRole"
    execution_role_arn = "arn:aws:iam::111111111111:role/CloudEcsTaskExecutionRole"

    container_info = {
      app_image = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/partner/front:latest"
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
    task_definition_name = "partner-frontend"
    ecs_service_name     = "partner-frontend"
  }

  backend = {
    dd_service         = "spring-gateway"
    task_role_arn      = "arn:aws:iam::111111111111:role/CloudEcsTaskRole"
    execution_role_arn = "arn:aws:iam::111111111111:role/CloudEcsTaskExecutionRole"

    container_info = {
      app_image = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/gateway"
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
      nginx_image  = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/acme/dev/spring-gateway-nginx"
      eureka_image = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/eureka:latest"
    }
    task_definition_name = "partner-gateway"
    ecs_service_name     = "partner-gateway"
  }

  common = {
    cluster_name = "acme-cloud"
    project      = "partner"
  }
}

beacon = {
  frontend = {
    dd_service         = "beacon-frontend"
    task_role_arn      = "arn:aws:iam::111111111111:role/CloudEcsTaskRole"
    execution_role_arn = "arn:aws:iam::111111111111:role/CloudEcsTaskExecutionRole"

    container_info = {
      app_image = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/beacon:latest"
      app_ports = [
        {
          protocol      = "tcp"
          containerPort = 8879
          hostPort      = 8879
        }
      ]
      app_dd_labels = {}
      nginx_image   = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/acme/dev/beacon-frontend-nginx:latest"
    }
    task_definition_name = "beacon-frontend"
    ecs_service_name     = "beacon-frontend"
  }

  backend = {
    dd_service         = "beacon-scan"
    task_role_arn      = "arn:aws:iam::111111111111:role/CloudEcsTaskRole"
    execution_role_arn = "arn:aws:iam::111111111111:role/CloudEcsTaskExecutionRole"

    container_info = {
      app_image = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/cloud/beacon/scan:latest"
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
    task_definition_name = "beacon-scan"
    ecs_service_name     = "beacon-scan"
  }

  common = {
    cluster_name = "acme-cloud"
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

variable "env" {
  default = "dev"
}

variable "mall" {
  type = object({
    frontend = object({
      dd_service         = string
      task_role_arn      = string
      execution_role_arn = string
      container_info = object({
        app_image = string
        app_ports = list(object({
          protocol      = string
          containerPort = number
          hostPort      = number
        }))
        app_dd_labels = map(any)
        nginx_image   = string
      })
      task_definition_name = string
      ecs_service_name     = string
    })
    backend = object({
      dd_service         = string
      task_role_arn      = string
      execution_role_arn = string
      container_info = object({
        app_image = string
        app_ports = list(object({
          protocol      = string
          containerPort = number
          hostPort      = number
        }))
        app_env       = map(any)
        app_dd_labels = map(any)
        nginx_image   = string
      })
      task_definition_name = string
      ecs_service_name     = string
    })
    common = map(any)
  })
}

variable "partner" {
  type = object({
    frontend = object({
      dd_service         = string
      task_role_arn      = string
      execution_role_arn = string
      container_info = object({
        app_image = string
        app_ports = list(object({
          protocol      = string
          containerPort = number
          hostPort      = number
        }))
        app_dd_labels = map(any)
        nginx_image   = string
      })
      task_definition_name = string
      ecs_service_name     = string
    })
    backend = object({
      dd_service         = string
      task_role_arn      = string
      execution_role_arn = string
      container_info = object({
        app_image = string
        app_ports = list(object({
          protocol      = string
          containerPort = number
          hostPort      = number
        }))
        app_dd_labels = map(any)
        nginx_image   = string
        eureka_image  = string
      })
      task_definition_name = string
      ecs_service_name     = string
    })
    common = map(any)
  })
}

variable "beacon" {
  type = object({
    frontend = object({
      dd_service         = string
      task_role_arn      = string
      execution_role_arn = string
      container_info = object({
        app_image = string
        app_ports = list(object({
          protocol      = string
          containerPort = number
          hostPort      = number
        }))
        app_dd_labels = map(any)
        nginx_image   = string
      })
      task_definition_name = string
      ecs_service_name     = string
    })

    backend = object({
      dd_service         = string
      task_role_arn      = string
      execution_role_arn = string
      container_info = object({
        app_image = string
        app_ports = list(object({
          protocol      = string
          containerPort = number
          hostPort      = number
        }))
        app_dd_labels = map(any)
      })
      task_definition_name = string
      ecs_service_name     = string
    })
    common = map(any)
  })
}

variable "dd_config" {
  type = map(any)
}

variable "dd_config_logs" {
  type = map(any)
}

variable "dd_config_metrics" {
  type = map(any)
}

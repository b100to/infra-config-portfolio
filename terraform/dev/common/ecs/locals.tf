locals {
  mall_frontend_dd_docker_labels = {
    dockerLabels = {
      "com.datadoghq.tags.service" = var.mall.frontend.dd_service
      "com.datadoghq.tags.env"     = var.env
    }
  }
  mall_backend_dd_docker_labels = {
    dockerLabels = {
      "com.datadoghq.tags.service" = var.mall.backend.dd_service
      "com.datadoghq.tags.env"     = var.env
    }
  }

  partner_frontend_dd_docker_labels = {
    dockerLabels = {
      "com.datadoghq.tags.service" = var.partner.frontend.dd_service
      "com.datadoghq.tags.env"     = var.env
    }
  }
  partner_backend_dd_docker_labels = {
    dockerLabels = {
      "com.datadoghq.tags.service" = var.partner.backend.dd_service
      "com.datadoghq.tags.env"     = var.env
    }
  }

  beacon_frontend_dd_docker_labels = {
    dockerLabels = {
      "com.datadoghq.tags.service" = var.beacon.frontend.dd_service
      "com.datadoghq.tags.env"     = var.env
    }
  }
  beacon_backend_dd_docker_labels = {
    dockerLabels = {
      "com.datadoghq.tags.service" = var.beacon.backend.dd_service
      "com.datadoghq.tags.env"     = var.env
    }
  }

  # DD container environments
  dd_container_env = merge(var.dd_config_metrics.default.environments,
    {
      DD_API_KEY = var.dd_config.api_key,
      DD_ENV     = var.env
    }
  )

  mall_frontend_dd_container_env = [for k, v in merge(local.dd_container_env, { DD_SERVICE = var.mall.frontend.dd_service }) :
  { name = k, value = v }]
  mall_backend_dd_container_env = [for k, v in merge(local.dd_container_env, { DD_SERVICE = var.mall.backend.dd_service }) :
  { name = k, value = v }]

  partner_frontend_dd_container_env = [for k, v in merge(local.dd_container_env, { DD_SERVICE = var.partner.frontend.dd_service }) :
  { name = k, value = v }]
  partner_backend_dd_container_env = [for k, v in merge(local.dd_container_env, { DD_SERVICE = var.partner.backend.dd_service }) :
  { name = k, value = v }]

  beacon_frontend_dd_container_env = [for k, v in merge(local.dd_container_env, { DD_SERVICE = var.beacon.frontend.dd_service }) :
  { name = k, value = v }]
  beacon_backend_dd_container_env = [for k, v in merge(local.dd_container_env, { DD_SERVICE = var.beacon.backend.dd_service }) :
  { name = k, value = v }]
}

# mall
data "aws_security_group" "frontend_mall" {
  filter {
    name   = "group-name"
    values = ["am-backend-ecs-sg"]
  }
}

data "aws_security_group" "backend_mall" {
  filter {
    name   = "group-name"
    values = ["am-backend-ecs-sg"]
  }
}

# partner
data "aws_security_group" "frontend_partner" {
  filter {
    name   = "group-name"
    values = ["cloud-partner-front00000000000000000000000001"]
  }
}

data "aws_security_group" "backend_partner" {
  filter {
    name   = "group-name"
    values = ["gateway"]
  }
}

# beacon-scan
data "aws_security_group" "frontend_beacon" {
  filter {
    name   = "group-name"
    values = ["beacon*"]
  }
}
data "aws_security_group" "backend_beacon" {
  filter {
    name   = "group-name"
    values = ["cloud-beacon-scan*"]
  }
}

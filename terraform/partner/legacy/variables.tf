variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = ""
}

variable "environment" {
  type = map(string)
  default = {
    dev   = "dev"
    stage = "stage"
    prod  = "prod"
  }
}

variable "route53_record" {
  description = "DNS choice"
  type        = map(string)
  default = {
    dev   = "acme-dev.example"
    stage = "acme.example"
    prod  = "acme.example"
  }
}

variable "rds_cluster" {
  default = {
    dev   = "acmemall-alpha"
    stage = "acmemall-staging-db"
    prod  = "acmemall-prod-db"
  }
}

variable "postfix_hyphen" {
  default = {
    dev : ""
    stage : "-stage"
    prod : ""
  }
}

variable "postfix_slash" {
  default = {
    dev : ""
    stage : "/stage"
    prod : ""
  }
}

variable "url" {
  default = {
    dev : "dev"
    stage : "example"
    prod : "example"
  }
}

variable "log_retention" {
  type = map(string)
  default = {
    dev   = 1
    stage = 3
    prod  = 14
  }
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "acme-cloud"
}

variable "api_gateway_service_count" {
  description = "api_gateway_service_count choice"
  type        = map(number)
  default = {
    dev   = 1
    stage = 1
    prod  = 2
  }
}

variable "partner_front_service_count" {
  description = "partner_front_service_count choice"
  type        = map(number)
  default = {
    dev   = 1
    stage = 1
    prod  = 2
  }
}

variable "partner_back_service_count" {
  description = "partner_back_service_count choice"
  type        = map(number)
  default = {
    dev   = 1
    stage = 1
    prod  = 2
  }
}


variable "nginx_name" {
  default = "cloud-api"
}

variable "fluentbit_image_url" {
  default = {
    dev   = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/fluentbit"
    stage = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/fluentbit"
    prod  = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/fluentbit"
  }
}
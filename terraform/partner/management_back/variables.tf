variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = ""
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

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

variable "environment" {
  type = map(string)
  default = {
    dev   = "dev"
    stage = "stage"
    prod  = "prod"
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

variable "log_retention" {
  type = map(string)
  default = {
    dev   = 1
    stage = 3
    prod  = 14
  }
}

variable "ecs_cluster" {
  default = {
    dev   = "acme-cloud"
    stage = "acme-cloud-stage"
    prod  = "acme-cloud"
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "acme-cloud"
}

variable "fluentbit_image_url" {
  default = {
    dev   = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/fluentbit"
    stage = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/fluentbit"
    prod  = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/fluentbit"
  }
}

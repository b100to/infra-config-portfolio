variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = ""
}

variable "front_record" {
  description = "DNS choice"
  type        = map(string)
  default = {
    dev   = "acmemall-dev.example"
    stage = "acme.example"
    prod  = "acme.example"
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

variable "alb_env" {
  default = {
    dev : "alpha"
    stage : "staging"
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

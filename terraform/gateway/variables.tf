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

variable "mall_zone" {
  description = "acmemall public zone"
  default = {
    dev   = "acmemall-dev.example"
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

variable "nginx_name" {
  default = "cloud-api"
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

variable "www" {
  default = {
    dev : ""
    stage : "stage"
    prod : "www"
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

variable "listener_arn" {
  default = {
    dev   = "arn:aws:elasticloadbalancing:ap-northeast-2:111111111111:listener/app/nginx-front/0000000000000000/0000000000000000"
    stage = "arn:aws:elasticloadbalancing:ap-northeast-2:222222222222:listener/app/nginx-front-stage/0000000000000000/0000000000000000"
    prod  = "arn:aws:elasticloadbalancing:ap-northeast-2:222222222222:listener/app/nginx-front/0000000000000000/0000000000000000"
  }
}

variable "fluentbit_image_url" {
  default = {
    dev   = "111111111111.dkr.ecr.ap-northeast-2.amazonaws.com/fluentbit"
    stage = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/fluentbit"
    prod  = "222222222222.dkr.ecr.ap-northeast-2.amazonaws.com/fluentbit"
  }
}

variable "lb_tg_arn" {
  type    = string
  default = "arn:aws:elasticloadbalancing:ap-northeast-2:222222222222:targetgroup/nginx-back/0000000000000000"
}

variable "lb_tg_name" {
  type    = string
  default = "nginx-back"
}

variable "lb_arn" {
  type    = string
  default = "arn:aws:elasticloadbalancing:ap-northeast-2:222222222222:loadbalancer/app/nginx-back/0000000000000000"
}

variable "lb_name" {
  type    = string
  default = "nginx-back"
}

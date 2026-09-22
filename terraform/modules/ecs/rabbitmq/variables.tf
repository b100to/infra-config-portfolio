variable "region" {
  description = "region"
  type        = string
  default     = "ap-northeast-2"
}

variable "log_retention" {
  description = "log retention"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}

variable "cluster" {
  description = "cluster name"
}

variable "image_name" {
  description = "Image name."
  type        = string
}

variable "image_url" {
  description = "Image url. e.g. `netfilx/eureka`"
  type        = string
}

variable "container_name" {
  description = "[Container, ecr, service, family, ALB, TG, SG...] combined name."
  type        = string
}

variable "container_port" {
  description = ""
  type        = number
}

variable "cpu" {
  description = "task CPU. unit: vCPU. one of 256, 512, 1024, 2048, 4096, 8194"
  type        = number
  default     = 512
}

variable "memory" {
  description = "task memory"
  type        = number
  default     = 1024
}

variable "execution_role_arn" {
  description = "execution task role arn"
  type        = string
}

variable "task_role_arn" {
  description = "task role arn"
  type        = string
}

variable "route53_record" {
  description = "DNS choice"
  type        = map(string)
  default = {
    dev  = "acme-dev.example"
    prod = "acme.example"
  }
}

variable "certificate_arn" {
  description = "certificate arn"
  type        = string
  default     = null
}

variable "desired_count" {
  description = "task_count choice"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "vpc"
  type        = string
}

variable "public_subnets" {
  description = "public_subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "private_subnets"
  type        = list(string)
}

variable "zone_name" {
  description = "zone name"
  type        = string
}

variable "zone_id" {
  description = "zone id"
  type        = string
}

variable "health_check_path" {
  description = "target group 헬스체크"
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "target group 유효 상태 코드 e.g. 200 또는 200-299"
  type        = string
  default     = "200-299"
}

#https://app.datadoghq.com/organization-settings/api-keys
variable "dd_api_key" {
  default = "REPLACE_ME_DD_API_KEY"
}

variable "dd_service" {
  description = "서비스 이름 넣기 ex(front, back, admin)"
}
#https://app.datadoghq.com/logs/pipelines/pipeline/library
variable "dd_source" {
  description = "ex(java, spring, django, fastapi)"
}

variable "dd_env" {
  description = "(dev, stage, prod)"
  default     = "dev"
}

variable "dd_project" {
  description = "프로젝트 이름 넣기 ex(partner, acmemall)"

}

variable "fluentbit_image_url" {
  description = "fluentbit image url"
  type        = string
}

variable "internal_route53_name" {
  description = "internal route53 name"
  type        = string
}

variable "taget_group_rabbit" {
  description = "taget_group_rabbit"
  type        = string
}
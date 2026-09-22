variable "env" {
  type = string
}

variable "frontend_acm_arn" {
  type = string
}

variable "backend_acm_arn" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "dns_records" {
  default = {
    frontend = "t-alpha"
    backend  = "t-apiv3"
  }
}

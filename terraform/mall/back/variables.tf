variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = "dev"
}

variable "environment" {
  type = map(string)
  default = {
    dev   = "dev"
    stage = "stage"
    prod  = "prod"
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

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "acmemall"
}

variable "internal_dns" {
  description = "acme internal DNS"
  type        = string
  default     = "acme.internal"
}
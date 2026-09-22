variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = ""
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

variable "ecs_cluster" {
  default = {
    dev   = "acmemall-alpha"
    stage = "acmemall-staging"
    prod  = "acmemall-prod"
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "acmemall"
}
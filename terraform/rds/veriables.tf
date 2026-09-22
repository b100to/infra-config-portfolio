variable "member" {
  type = object({
    engine         = string
    engine_version = string
    instance_type  = string

    backup_retention_period = number

    db_port = number
  })
}

variable "profile" {}

variable "password" {
  type      = string
  sensitive = true
}
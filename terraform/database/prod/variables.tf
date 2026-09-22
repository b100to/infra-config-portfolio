variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = "aurora-mysql"
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "5.7.mysql_aurora.2.07.2"
}

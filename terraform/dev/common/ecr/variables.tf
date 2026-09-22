variable "env" {
  type = string
}

variable "repos" {
  type    = set(string)
  default = []
}

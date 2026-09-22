variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = ""
}

variable "environment" {
  type = map(string)
  default = {
    dev   = "dev"
    stage = "stage"
    prod  = "prod"
  }
}
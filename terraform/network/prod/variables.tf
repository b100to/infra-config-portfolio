################################################################################
# VPC Module Inputs
################################################################################
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "acme"
}

variable "cidr" {
  description = ""
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default = [
    "10.0.16.0/20", // ap-northeast-2a
    "10.0.64.0/20", // ap-northeast-2c
  ]
}

variable "intra_subnets" {
  description = "A list of intra subnets"
  type        = list(string)
  default = [
    "10.0.32.0/20", // ap-northeast-2a
    "10.0.80.0/20", // ap-northeast-2c
  ]
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default = [
    "10.0.0.0/20",  // ap-northeast-2a
    "10.0.48.0/20", // ap-northeast-2c
  ]
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = string
  default     = "ap-northeast-2.compute.internal"
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

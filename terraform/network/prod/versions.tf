terraform {
  required_version = "~> 1.0.1"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      name = "network-prod"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.15"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  required_version = "~> 1.1.2"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      prefix = "mall-backend-path-alb-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }
}
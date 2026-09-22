provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  required_version = "~> 1.1.2"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      prefix = "mall-front-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }
}

#terraform {
#  required_version = "~> 1.1"
#
#  backend "s3" {
#    bucket = "terraform-state-example"
#    key    = "mall/front.tfstate"
#    region = "ap-northeast-2"
#  }
#
#  required_providers {
#    aws = {
#      source  = "hashicorp/aws"
#      version = "~> 3.70.0"
#    }
#  }
#}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      # security-stage 가 없으므로 vpc-prod 사용
      name = "network-${local.env == var.environment.dev ? var.environment.dev : var.environment.prod}"
    }
  }
}

data "terraform_remote_state" "security" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      # security-stage 가 없으므로 security-prod 사용
      name = "security-${local.env == var.environment.dev ? var.environment.dev : var.environment.prod}"
    }
  }
}

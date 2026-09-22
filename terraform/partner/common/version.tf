provider "aws" {
  region = local.region
}

terraform {
  required_version = "~> 1.1.2"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      prefix = "common-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }
}

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

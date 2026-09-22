provider "aws" {
  region  = local.region
  profile = var.profile
}

terraform {
  required_version = "~> 1.0.11"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      prefix = "member-rds-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      # security-stage 가 없으므로 vpc-prod 사용
      name = "network-${var.profile}"
    }
  }
}

data "terraform_remote_state" "security" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      # security-stage 가 없으므로 security-prod 사용
      name = "security-${var.profile}"
    }
  }
}

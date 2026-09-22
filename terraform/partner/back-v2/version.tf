provider "aws" {
  region = local.region
}

terraform {
  required_version = "~> 1.1.7"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      prefix = "partner-back-v2-"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      # security-stage 가 없으므로 vpc-prod 사용
      name = "network-${local.remote_env[local.env]}"
    }
  }
}

data "terraform_remote_state" "security" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      # security-stage 가 없으므로 security-prod 사용
      name = "security-${local.remote_env[local.env]}"
    }
  }
}

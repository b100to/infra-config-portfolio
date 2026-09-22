provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  required_version = "~> 1.0.1"

  backend "remote" {
    organization = "acme"

    workspaces {
      name = "acme-infra-common-alb-dev"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71"
    }
  }
}

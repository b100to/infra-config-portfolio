provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  required_version = "~> 1.1.7"

  backend "remote" {
    organization = "acme"

    workspaces {
      name = "acme-infra-common-ecr-stage"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

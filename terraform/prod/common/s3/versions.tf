provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  required_version = "~> 1.0.11"

  backend "remote" {
    organization = "acme"

    workspaces {
      name = "acme-infra-common-s3-prod"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
}

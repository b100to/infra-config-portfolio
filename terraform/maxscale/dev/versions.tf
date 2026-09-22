terraform {
  required_version = "~> 1.0.1"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      name = "maxscale-dev"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.15"
    }
  }
}

data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      name = "network-dev"
    }
  }
}

terraform {
  required_version = "~> 1.0.1"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      name = "security-prod"
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
      name = "network-prod"
    }
  }
}

data "terraform_remote_state" "vpc_dev" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      name = "network-dev"
    }
  }
}

data "terraform_remote_state" "database" {
  backend = "remote"

  config = {
    organization = "acme"
    workspaces = {
      name = "database-prod"
    }
  }
}

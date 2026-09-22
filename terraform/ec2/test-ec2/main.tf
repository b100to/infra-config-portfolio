provider "aws" {
  region  = "ap-northeast-2"
  profile = "dev"
}

terraform {
  required_version = "~> 1.1.2"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "acme"

    workspaces {
      name = "performance-test-dev"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
  }
}
resource "aws_instance" "this" {
  ami               = "ami-00000000000000002"
  availability_zone = "ap-northeast-2a"
  instance_type     = "t3.large"
  key_name          = "acme-internal"
  tags = {
    "Name"      = "performance-test"
    "Terraform" = "true"
  }
  tags_all = {
    "Name"      = "performance-test"
    "Terraform" = "true"
  }
  vpc_security_group_ids = [
    "sg-0000000000000004"
  ]
}
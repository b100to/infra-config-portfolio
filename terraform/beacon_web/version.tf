provider "aws" {
  region = "ap-northeast-2"
}
terraform {
  required_version = "~> 1.0.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63.0"
    }
  }
}
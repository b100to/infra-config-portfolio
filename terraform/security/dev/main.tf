provider "aws" {
  region = local.region
}

locals {
  region            = "ap-northeast-2"
  account_id        = data.aws_caller_identity.current.account_id
  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block    = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  office_cidr_block = "203.0.113.7/32"

  airflow_s3_bucket = "acme-airflow-dev"

  tags = {
    Terraform          = "true"
    Environment        = "dev"
    TerraformWorkspace = "security"
  }
}

data "aws_caller_identity" "current" {}

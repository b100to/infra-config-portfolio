provider "aws" {
  region = local.region
}

locals {
  region            = "ap-northeast-2"
  account_id        = data.aws_caller_identity.current.account_id
  office_cidr_block = "203.0.113.7/32"
  cs_cidr_block     = "203.0.113.6/32" // Acme CS NAT gateway in separated network

  vpc_id                       = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block               = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  database_allowed_cidr_blocks = data.terraform_remote_state.vpc.outputs.database_allowed_cidr_blocks
  nat_public_ips               = data.terraform_remote_state.vpc.outputs.nat_public_ips

  dev_nat_public_ips = data.terraform_remote_state.vpc_dev.outputs.nat_public_ips

  legacy_vpc_id = "vpc-00000001"

  airflow_s3_bucket  = "acme-airflow-prod"
  datalake_s3_bucket = "acme.datalake.prod"

  airflow_sg = "sg-0000000000000001"
  redash_sg  = "sg-0000000000000005"

  tags = {
    Terraform          = "true"
    Environment        = "prod"
    TerraformWorkspace = "security"
  }
}

data "aws_caller_identity" "current" {}

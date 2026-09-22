locals {
  env        = regex(join("|", values(local.environment)), "${terraform.workspace}")
  region     = "ap-northeast-2"
  account_id = data.aws_caller_identity.current.account_id

  environment = {
    dev   = "dev"
    stage = "stage"
    prod  = "prod"
  }
  remote_env = {
    dev   = "dev"
    stage = "prod"
    prod  = "prod"
  }

  tags = {
    Terraform   = "true"
    Environment = local.env
  }
}


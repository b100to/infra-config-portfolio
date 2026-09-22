locals {

  env = regex(join("|", values(var.environment)), var.TFC_WORKSPACE_NAME)

  region = "ap-northeast-2"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets

  account_id = data.aws_caller_identity.current.account_id

  url_prefix = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"

  acm_arn = "arn:aws:acm:ap-northeast-2:111111111111:certificate/00000000-0000-4000-8000-000000000014"

  required_tags = {
    Project     = var.project_name
    Environment = local.env
  }
  tags = merge(var.resource_tags, local.required_tags)
}
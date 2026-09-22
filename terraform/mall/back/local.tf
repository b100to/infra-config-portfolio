locals {
  region     = "ap-northeast-2"
  env        = regex(join("|", values(var.environment)), var.TFC_WORKSPACE_NAME)
  account_id = data.aws_caller_identity.current.account_id

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets

}

provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-2"

  account_id = data.aws_caller_identity.current.account_id

  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets    = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnet_2a = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  default_sg        = data.terraform_remote_state.security.outputs.security_group_default

  codepipeline_artifact_s3_bucket = "codepipeline-ap-northeast-2-00000000000"

  tags = {
    Terraform          = "true"
    Environment        = "prod"
    TerraformWorkspace = "beacon"
  }
}

data "aws_caller_identity" "current" {}

data "aws_canonical_user_id" "current_user" {}

data "aws_iam_policy" "amazon_s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "aws_codedeploy_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

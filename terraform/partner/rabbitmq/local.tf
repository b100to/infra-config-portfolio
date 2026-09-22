locals {

  env = regex(join("|", values(var.environment)), var.TFC_WORKSPACE_NAME)

  region = "ap-northeast-2"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets

  postfix_hyphen = var.postfix_hyphen[local.env]
  postfix_slash  = var.postfix_slash[local.env]

  account_id = data.aws_caller_identity.current.account_id

  image_url_prefix = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"

  beacon_image_name     = "rabbitmq${local.postfix_slash}"
  beacon_image_url      = join("/", [local.image_url_prefix, local.beacon_image_name])
  beacon_image_tag      = "latest"
  beacon_container_name = "rabbitmq${local.postfix_hyphen}"
  beacon_container_port = 5672

    spec = {
    cpu = {
      dev   = 512
      stage = 512
      prod  = 512
    }
    memory = {
      dev   = 1024
      stage = 1024
      prod  = 1024
    }
  }

  dd_project = "partner${local.postfix_hyphen}"
  dd_service = "rabbitmq${local.postfix_hyphen}"
  dd_source  = "none"

  required_tags = {
    Project     = "${var.project_name}${local.postfix_hyphen}"
    Environment = local.env
  }
  tags = merge(var.resource_tags, local.required_tags)
}
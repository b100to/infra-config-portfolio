locals {

  env = regex(join("|", values(var.environment)), var.TFC_WORKSPACE_NAME)

  region = "ap-northeast-2"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets

  log_retention  = var.log_retention[local.env]
  postfix_hyphen = var.postfix_hyphen[local.env]
  postfix_slash  = var.postfix_slash[local.env]

  account_id = data.aws_caller_identity.current.account_id

  image_url_prefix = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"

  beacon_image_name     = "cloud/beacon/scan${local.postfix_slash}"
  beacon_image_url      = join("/", [local.image_url_prefix, local.beacon_image_name])
  beacon_image_tag      = "latest"
  back_gateway_image   = join("/", [local.image_url_prefix, "test-spring-gateway-nginx"])
  beacon_container_name = "cloud-beacon-scan${local.postfix_hyphen}"
  beacon_container_port = 80

  dd_project = "partner${local.postfix_hyphen}"
  dd_service = "beacon_scan${local.postfix_hyphen}"
  dd_source  = "python"

  required_tags = {
    Project     = "${var.project_name}${local.postfix_hyphen}"
    Environment = local.env
  }
  tags = merge(var.resource_tags, local.required_tags)
}

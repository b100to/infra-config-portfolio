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

  dd_project = "partner"
  dd_source  = "java"

  api_gateway_image_name     = "cloud/gateway${local.postfix_slash}"
  api_gateway_image_url      = join("/", [local.image_url_prefix, local.api_gateway_image_name])
  api_gateway_image_tag      = "latest"
  api_gateway_container_name = "gateway${local.postfix_hyphen}"
  api_gateway_container_port = 8088

  eureka_image_name     = "cloud/eureka${local.postfix_slash}"
  eureka_image_url      = join("/", [local.image_url_prefix, local.eureka_image_name])
  eureka_image_tag      = "latest"
  eureka_container_name = "eureka${local.postfix_hyphen}"
  eureka_container_port = 8761

  partner_back_image_name     = "cloud/partner/back${local.postfix_slash}"
  partner_back_image_url      = join("/", [local.image_url_prefix, local.partner_back_image_name])
  partner_back_image_tag      = "latest"
  back_gateway_image           = join("/", [local.image_url_prefix, "test-spring-gateway-nginx"])
  partner_back_container_name = "partner-back${local.postfix_hyphen}"
  partner_back_container_port = 8080


  acme_user_image_name     = "cloud/user${local.postfix_slash}"
  acme_user_image_url      = join("/", [local.image_url_prefix, local.acme_user_image_name])
  acme_user_image_tag      = "latest"
  acme_user_container_name = "acme-user${local.postfix_hyphen}"
  acme_user_container_port = 8871

  acme_demo_image_name     = "cloud/demo${local.postfix_slash}"
  acme_demo_image_url      = join("/", [local.image_url_prefix, local.acme_demo_image_name])
  acme_demo_image_tag      = "latest"
  acme_demo_container_name = "acme-demo${local.postfix_hyphen}"
  acme_demo_container_port = 8873

  beacon_ecr_name       = "cloud/beacon${local.postfix_slash}"
  beacon_ecr_url        = join("/", [local.image_url_prefix, local.beacon_ecr_name])
  beacon_image_tag      = "latest"
  beacon_container_name = "beacon${local.postfix_hyphen}"
  beacon_container_port = 8879

  cpu = {
    java = {
      dev   = 512
      stage = 512
      prod  = 4096
    }
  }
  memory = {
    java = {
      dev   = 1024
      stage = 1024
      prod  = 8192
    }
  }

  required_tags = {
    Project     = "${var.project_name}${local.postfix_hyphen}"
    Environment = local.env
  }
  tags = merge(var.resource_tags, local.required_tags)
}

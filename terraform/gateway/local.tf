locals {

  env = regex(join("|", values(var.environment)), var.TFC_WORKSPACE_NAME)

  region = "ap-northeast-2"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets  = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets

  log_retention  = var.log_retention[local.env]
  postfix_hyphen = var.postfix_hyphen[local.env]
  postfix_slash  = var.postfix_slash[local.env]
  www            = var.www[local.env]

  account_id = data.aws_caller_identity.current.account_id

  image_url_prefix = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"

  dd_project = "nigx_gateway${local.postfix_hyphen}"
  dd_source  = "nginx"

  front = {
    image_name             = "nginx/front${local.postfix_slash}"
    image_url              = "${local.image_url_prefix}/nginx/front${local.postfix_slash}"
    image_tag              = "latest"
    container_name         = "nginx-front${local.postfix_hyphen}"
    container_port         = 80
    route53_name           = local.www
    evaluate_target_health = "true"
    dd_service             = "nignx_front${local.postfix_hyphen}"

    task_role_arn      = data.aws_iam_role.task.arn
    execution_role_arn = data.aws_iam_role.TaskExecution.arn

  }
  back = {
    image_name     = "nginx/back${local.postfix_slash}"
    image_url      = "${local.image_url_prefix}/nginx/back${local.postfix_slash}"
    image_tag      = "latest"
    container_name = "nginx-back${local.postfix_hyphen}"
    container_port = 80
    route53_name   = "apiv3${local.postfix_hyphen}"
    dd_service     = "nignx_back${local.postfix_hyphen}"

    task_role_arn      = data.aws_iam_role.task.arn
    execution_role_arn = data.aws_iam_role.TaskExecution.arn
  }

  required_tags = {
    Project     = "${var.nginx_name}${local.postfix_hyphen}"
    Environment = local.env
  }
  tags = merge(var.resource_tags, local.required_tags)
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.project_name}${local.postfix_hyphen}"
  retention_in_days = local.log_retention

  tags = local.tags
}

module "ecs" {
  source             = "terraform-aws-modules/ecs/aws"
  version            = "~> 3.4.1"
  name               = "${var.project_name}${local.postfix_hyphen}"
  container_insights = true

  tags = local.tags
}

module "gateway" {
  source  = "../../modules/ecs/multi_task"
  cluster = module.ecs.ecs_cluster_id

  vpc_id          = local.vpc_id
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  cpu    = local.cpu.java[local.env]
  memory = local.memory.java[local.env]

  image_name       = local.api_gateway_image_name
  image_url        = "${local.api_gateway_image_url}:${local.api_gateway_image_tag}"
  log_router_image = var.fluentbit_image_url[local.env]

  container_name = local.api_gateway_container_name
  container_port = local.api_gateway_container_port

  second_image_name = local.eureka_image_name
  second_image_url  = "${local.eureka_image_url}:${local.eureka_image_tag}"

  back_gateway_image    = local.back_gateway_image
  second_container_name = local.eureka_container_name
  second_container_port = local.eureka_container_port

  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  zone_name = data.aws_route53_zone.this.name
  zone_id   = data.aws_route53_zone.this.zone_id

  certificate_arn = data.aws_acm_certificate.cert.arn

  log_group = aws_cloudwatch_log_group.log_group.name

  dd_env     = local.env
  dd_project = "${local.dd_project}${local.postfix_hyphen}"

  dd_source        = local.dd_source
  dd_second_source = local.dd_source

  dd_service        = local.api_gateway_container_name
  dd_second_service = local.eureka_container_name



  tags = local.tags
}

module "demo" {
  source  = "../../modules/ecs/single_task"
  cluster = module.ecs.ecs_cluster_id

  vpc_id          = local.vpc_id
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  cpu    = local.cpu.java[local.env]
  memory = local.memory.java[local.env]

  image_name          = local.acme_demo_image_name
  image_url           = "${local.acme_demo_image_url}:${local.acme_demo_image_tag}"
  fluentbit_image_url = var.fluentbit_image_url[local.env]

  container_name = local.acme_demo_container_name
  container_port = local.acme_demo_container_port

  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  zone_name = data.aws_route53_zone.this.name
  zone_id   = data.aws_route53_zone.this.zone_id

  log_group = aws_cloudwatch_log_group.log_group.name

  dd_env     = local.env
  dd_project = "${local.dd_project}${local.postfix_hyphen}"
  dd_source  = local.dd_source

  dd_service = local.acme_demo_container_name

  tags = local.tags
}

module "acme-user" {
  source  = "../../modules/ecs/single_task"
  cluster = module.ecs.ecs_cluster_id

  vpc_id          = local.vpc_id
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  cpu    = local.cpu.java[local.env]
  memory = local.memory.java[local.env]

  image_name          = local.acme_user_image_name
  image_url           = "${local.acme_user_image_url}:${local.acme_user_image_tag}"
  fluentbit_image_url = var.fluentbit_image_url[local.env]

  container_name = local.acme_user_container_name
  container_port = local.acme_user_container_port

  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  zone_name = data.aws_route53_zone.this.name
  zone_id   = data.aws_route53_zone.this.zone_id

  log_group = aws_cloudwatch_log_group.log_group.name

  dd_env     = local.env
  dd_project = "${local.dd_project}${local.postfix_hyphen}"
  dd_source  = local.dd_source

  dd_service = local.acme_user_container_name

  tags = local.tags
}

module "partner-back" {
  source  = "../../modules/ecs/single_task"
  cluster = module.ecs.ecs_cluster_id

  vpc_id          = local.vpc_id
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  cpu    = local.cpu.java[local.env]
  memory = local.memory.java[local.env]

  image_name          = local.partner_back_image_name
  image_url           = "${local.partner_back_image_url}:${local.partner_back_image_tag}"
  fluentbit_image_url = var.fluentbit_image_url[local.env]

  container_name = local.partner_back_container_name
  container_port = local.partner_back_container_port

  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  zone_name = data.aws_route53_zone.this.name
  zone_id   = data.aws_route53_zone.this.zone_id

  log_group = aws_cloudwatch_log_group.log_group.name

  dd_env     = local.env
  dd_project = "${local.dd_project}${local.postfix_hyphen}"
  dd_source  = local.dd_source

  dd_service = local.partner_back_container_name

  tags = local.tags
}

module "beacon" {
  source  = "../../modules/ecs/single_task"
  cluster = module.ecs.ecs_cluster_id

  vpc_id          = local.vpc_id
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  cpu    = local.cpu.java[local.env]
  memory = local.memory.java[local.env]

  image_name          = local.beacon_ecr_name
  image_url           = "${local.beacon_ecr_url}:${local.beacon_image_tag}"
  fluentbit_image_url = var.fluentbit_image_url[local.env]

  container_name = local.beacon_container_name
  container_port = local.beacon_container_port

  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  zone_name = data.aws_route53_zone.this.name
  zone_id   = data.aws_route53_zone.this.zone_id

  log_group = aws_cloudwatch_log_group.log_group.name

  dd_env     = local.env
  dd_project = "${local.dd_project}${local.postfix_hyphen}"
  dd_source  = local.dd_source

  dd_service = local.beacon_container_name

  tags = local.tags
}



provider "aws" {
  region = local.region
}

module "cloud_config" {
  source = "../../modules/ecs/single_task"

  cluster = data.aws_ecs_cluster.this.cluster_name

  vpc_id          = local.vpc_id
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  image_name          = local.image_name
  image_url           = "${local.image_url}:${local.image_tag}"
  fluentbit_image_url = var.fluentbit_image_url[local.env]

  container_name = local.container_name
  container_port = local.container_port

  task_role_arn      = data.aws_iam_role.task.arn
  execution_role_arn = data.aws_iam_role.TaskExecution.arn

  cpu    = local.spec.cpu[local.env]
  memory = local.spec.memory[local.env]

  zone_name = data.aws_route53_zone.this.name
  zone_id   = data.aws_route53_zone.this.zone_id

  log_group = data.aws_cloudwatch_log_group.this.name
  tags      = local.tags

  dd_project = local.dd_project
  dd_service = local.dd_service
  dd_source  = local.dd_source
}
provider "aws" {
  region = local.region
}

module "nginx_cluster" {
  source             = "terraform-aws-modules/ecs/aws"
  version            = "~> 3.4.0"
  name               = "${var.nginx_name}${local.postfix_hyphen}"
  container_insights = true

  tags = local.tags
}

module "front" {
  source  = "../modules/gateway"
  cluster = module.nginx_cluster.ecs_cluster_id

  vpc_id          = local.vpc_id
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  image_name          = local.front.image_name
  image_url           = local.front.image_url
  fluentbit_image_url = var.fluentbit_image_url[local.env]

  container_name = local.front.container_name
  container_port = local.front.container_port
  cpu            = 1024
  memory         = 4096

  task_role_arn      = local.front.task_role_arn
  execution_role_arn = local.front.execution_role_arn

  route53_name           = local.front.route53_name
  zone_name              = data.aws_route53_zone.front.name
  zone_id                = data.aws_route53_zone.front.zone_id
  evaluate_target_health = local.front.evaluate_target_health

  log_group       = data.aws_cloudwatch_log_group.this.name
  certificate_arn = data.aws_acm_certificate.front.arn

  dd_env = local.env

  dd_project = local.dd_project
  dd_service = local.front.dd_service
  dd_source  = local.dd_source

  tags = local.tags
}

module "back" {
  source  = "../modules/gateway"
  cluster = module.nginx_cluster.ecs_cluster_id

  vpc_id          = local.vpc_id
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  image_name          = local.back.image_name
  image_url           = local.back.image_url
  fluentbit_image_url = var.fluentbit_image_url[local.env]

  container_name = local.back.container_name
  container_port = local.back.container_port
  cpu            = 1024
  memory         = 4096

  task_role_arn      = local.back.task_role_arn
  execution_role_arn = local.back.execution_role_arn

  route53_name = local.back.route53_name
  zone_name    = data.aws_route53_zone.back.name
  zone_id      = data.aws_route53_zone.back.zone_id

  log_group       = data.aws_cloudwatch_log_group.this.name
  certificate_arn = data.aws_acm_certificate.back.arn

  dd_env = local.env

  dd_project = local.dd_project
  dd_service = local.back.dd_service
  dd_source  = local.dd_source

  tags = local.tags
}

resource "aws_route53_record" "h_cname" {
  name    = "*.${var.mall_zone[local.env]}"
  records = ["www.${var.mall_zone[local.env]}"]
  ttl     = "300"
  type    = "CNAME"
  zone_id = data.aws_route53_zone.front.zone_id
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = data.aws_alb.back.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.front.arn

  default_action {
    type             = "forward"
    target_group_arn = data.aws_alb_target_group.back.arn
  }
}
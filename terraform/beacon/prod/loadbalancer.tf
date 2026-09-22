############################
# Application Load Balancer
############################
module "beacon_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "acme-beacon-elb"

  load_balancer_type = "application"

  vpc_id          = local.vpc_id
  subnets         = local.public_subnets
  security_groups = [local.default_sg]

  target_groups = [
    {
      name             = "acme-beacon-route"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:acm:ap-northeast-2:${local.account_id}:certificate/00000000-0000-4000-8000-000000000005"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = local.tags
}

module "beacon_celery_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "acme-beacon-celery-elb"

  load_balancer_type = "application"

  vpc_id          = local.vpc_id
  subnets         = local.public_subnets
  security_groups = [local.default_sg]

  target_groups = [
    {
      name             = "acme-beacon-celery-route"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:acm:ap-northeast-2:${local.account_id}:certificate/00000000-0000-4000-8000-000000000005"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = local.tags
}
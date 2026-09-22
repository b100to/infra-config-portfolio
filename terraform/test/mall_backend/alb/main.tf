module "back_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "back-alb"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups = [data.terraform_remote_state.security.outputs.security_group_default]

  target_groups = [
    {
      name             = "back-tg-mall"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        interval            = 30
        path                = "/ht/"
        healthy_threshold   = 5
        unhealthy_threshold = 5
      }
      stickiness = {
        enabled = false
        type    = "lb_cookie"
      }
    },
    {
      name             = "back-tg-h"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    },
    {
      name             = "back-tg-beacon-ins"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]
  https_listener_rules = [
    {
      https_listener_index = 0

      actions = [{
        type               = "forward"
        target_group_index = 0
      }]

      conditions = [{
        path_patterns = ["/mall", "/mall/*"]
      }]
    },
    {
      https_listener_index = 0

      actions = [{
        type               = "forward"
        target_group_index = 1
      }]

      conditions = [{
        path_patterns = ["/h", "/h/*"]
      }]
    },
    {
      https_listener_index = 0

      actions = [{
        type               = "forward"
        target_group_index = 2
      }]

      conditions = [{
        path_patterns = ["/beacon/basic", "/beacon/basic/*", "/beacon/extended", "/beacon/extended/*"]
      }]
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = local.acm_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "cloud-api"
  }
}

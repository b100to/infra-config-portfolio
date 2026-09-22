module "frontend_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "frontend-alb-stg"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups = [data.terraform_remote_state.security.outputs.security_group_default]

  target_groups = [
    {
      name             = "frontend-tg-mall-stg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        interval            = 20
        path                = "/mall"
        healthy_threshold   = 5
        unhealthy_threshold = 3
      }
      stickiness = {
        enabled = false
        type    = "lb_cookie"
      }
    },
    {
      name             = "frontend-tg-partner-stg"
      backend_protocol = "HTTP"
      backend_port     = 7001
      target_type      = "ip"
      health_check = {
        interval            = 20
        path                = "/h"
        healthy_threshold   = 5
        unhealthy_threshold = 3
      }
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

      actions = [
        {
          type               = "redirect"
          status_code        = "HTTP_302"
          terget_group_index = 0
          protocol           = "HTTPS"
          path               = "/mall"
        }
      ]

      conditions = [
        {
          path_patterns = ["/"]
        }
      ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.frontend_acm_arn
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
    Environment = var.env
    Terraform   = "true"
    Project     = "infra"
  }

  access_logs = {
    bucket = data.terraform_remote_state.infra_common_s3.outputs.frontend_bucket_id
  }
}

module "backend_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "backend-alb-stg"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets         = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups = [data.terraform_remote_state.security.outputs.security_group_default]

  target_groups = [
    {
      name             = "backend-tg-partner-stg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        interval            = 20
        path                = "/"
        healthy_threshold   = 5
        unhealthy_threshold = 3
      }
    },
    {
      name             = "backend-tg-mall-stg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        interval            = 20
        path                = "/ht-status"
        healthy_threshold   = 5
        unhealthy_threshold = 3
        matcher             = "200,301,302"
      }
      stickiness = {
        enabled = false
        type    = "lb_cookie"
      }
    },
    {
      name             = "backend-tg-beacon-scan-stg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
      health_check = {
        interval            = 20
        path                = "/"
        healthy_threshold   = 5
        unhealthy_threshold = 3
        matcher             = "200"
      }
      stickiness = {
        enabled = false
        type    = "lb_cookie"
      }
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
        path_patterns = ["/h", "/h/*"]
      }]
    },
    {
      https_listener_index = 0

      actions = [{
        type               = "forward"
        target_group_index = 1
      }]

      conditions = [{
        path_patterns = ["/mall", "/mall/*"]
      }]
    },
    {
      https_listener_index = 0

      actions = [{
        type               = "forward"
        target_group_index = 2
      }]

      conditions = [{
        path_patterns        = ["/beacon/basic/scans", "/beacon/extended/scans"]
        http_request_methods = ["POST"]
      }]
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.backend_acm_arn
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
    Environment = var.env
    Terraform   = "true"
    Project     = "infra"
  }

  access_logs = {
    bucket = data.terraform_remote_state.infra_common_s3.outputs.backend_bucket_id
  }
}

#nlb
resource "aws_lb" "internal" {
  name               = "gateway-nlb-stg"
  internal           = true
  load_balancer_type = "network"
  subnets            = data.terraform_remote_state.vpc.outputs.private_subnets

  enable_deletion_protection = true

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = "infra"
  }
}
# stickiness가 테라폼 오류로 먹히지가 않음
resource "aws_lb_target_group" "internal" {
  name        = "gateway-internal-stg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = "infra"
  }
}

resource "aws_lb_listener" "internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal.arn
  }
}
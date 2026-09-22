resource "aws_alb" "cloud" {
  name    = "alb-${var.project_name}${local.postfix_hyphen}"
  subnets = local.public_subnets
  security_groups = [
    aws_security_group.sg_http.id
  ]
}

resource "aws_alb_target_group" "alb_partner" {
  name        = "tg-${var.project_name}${local.postfix_hyphen}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "cloud_https" {
  load_balancer_arn = aws_alb.cloud.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_partner.arn
  }
}

resource "aws_alb_listener" "cloud_http" {
  load_balancer_arn = aws_alb.cloud.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_partner.arn
  }
}



resource "aws_alb" "alb_acme_user" {
  name    = "alb-acme-user${local.postfix_hyphen}"
  subnets = local.public_subnets
  security_groups = [
    aws_security_group.acme_user_sg.id
  ]
}

resource "aws_alb_target_group" "tg_acme_user" {
  name        = "tg-acme-user${local.postfix_hyphen}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"
}

resource "aws_alb_listener" "alb_acme_user_http" {
  load_balancer_arn = aws_alb.alb_acme_user.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg_acme_user.arn
  }
}

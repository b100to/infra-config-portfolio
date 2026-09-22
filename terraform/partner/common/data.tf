data "aws_region" "region" {}

data "aws_route53_zone" "internal" {
  name         = local.internal
  private_zone = "true"
}

data "aws_lb" "beacon" {
  name = "beacon${local.postfix_hyphen}"
}

data "aws_lb" "hm_back" {
  name = "elb-am-backend-${local.alb_env}-ecs"
}

data "aws_lb" "hm_front" {
  name = "elb-am-front-${local.alb_env}-ecs"
}
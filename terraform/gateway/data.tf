data "aws_route53_zone" "front" {
  name         = var.mall_zone[local.env]
  private_zone = false
}

data "aws_route53_zone" "back" {
  name         = var.route53_record[local.env]
  private_zone = false
}

data "aws_acm_certificate" "front" {
  domain      = "*.${var.mall_zone[local.env]}"
  most_recent = true
}

data "aws_acm_certificate" "back" {
  domain = "*.${var.route53_record[local.env]}"
}

data "aws_cloudwatch_log_group" "this" {
  name = "acme-cloud${local.postfix_hyphen}"
}

data "aws_iam_role" "task" {
  name = "CloudEcsTaskRole${local.postfix_hyphen}"
}

data "aws_iam_role" "TaskExecution" {
  name = "CloudEcsTaskExecutionRole${local.postfix_hyphen}"
}

data "aws_caller_identity" "account" {}

data "aws_region" "region" {}

data "aws_alb" "back" {
  arn  = var.lb_arn
  name = var.lb_name
}

data "aws_alb_target_group" "back" {
  arn  = var.lb_tg_arn
  name = var.lb_tg_name
}

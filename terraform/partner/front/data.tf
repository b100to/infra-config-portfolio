data "aws_region" "region" {}

data "aws_ecs_cluster" "this" {
  cluster_name = var.ecs_cluster[local.env]
}

data "aws_caller_identity" "account" {}

data "aws_acm_certificate" "cert" {
  domain   = "*.${var.route53_record[local.env]}"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "zone" {
  name = var.route53_record[local.env]
}

data "aws_route53_zone" "this" {
  name         = "acme.internal"
  private_zone = true
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



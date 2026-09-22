locals {
  zone_id   = data.aws_route53_zone.external.zone_id
  zone_name = data.aws_route53_zone.external.name
  acm_arn   = "arn:aws:acm:ap-northeast-2:111111111111:certificate/00000000-0000-4000-8000-000000000014"
}

data "aws_route53_zone" "external" {
  name = "acme-dev.example"
}
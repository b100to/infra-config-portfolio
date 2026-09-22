data "aws_route53_zone" "zone" {
  name = var.route53_record[local.env]
}

resource "aws_route53_zone" "acme_internal" {
  count = local.env == "prod" ? 0 : 1
  name  = "acme.internal"

  vpc {
    vpc_id = local.vpc_id
  }

  tags = local.tags
}

resource "aws_route53_record" "api_cloud" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "gateway${local.postfix_hyphen}.${var.route53_record[local.env]}"
  type    = "A"

  alias {
    name                   = module.gateway.dns_name
    zone_id                = module.gateway.zone_id
    evaluate_target_health = "false"
  }
}

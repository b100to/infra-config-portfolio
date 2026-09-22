resource "aws_route53_record" "acme_front" {
  name    = "test-apiv3.${local.zone_name}"
  zone_id = local.zone_id
  type    = "A"

  alias {
    evaluate_target_health = "true"
    name                   = module.back_alb.lb_dns_name
    zone_id                = module.back_alb.lb_zone_id
  }
}


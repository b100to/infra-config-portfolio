resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = var.route53_name
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = "false"
  }
}
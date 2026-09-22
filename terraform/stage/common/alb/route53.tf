#resource "aws_route53_record" "frontend" {
#  name    = format("%s.%s", var.dns_records.frontend, var.zone_name)
#  zone_id = var.zone_id
#  type    = "A"
#
#  alias {
#    evaluate_target_health = "true"
#    name                   = module.frontend_alb.lb_dns_name
#    zone_id                = module.frontend_alb.lb_zone_id
#  }
#}
#
#resource "aws_route53_record" "backend" {
#  name    = format("%s.%s", var.dns_records.backend, var.zone_name)
#  zone_id = var.zone_id
#  type    = "A"
#
#  alias {
#    evaluate_target_health = "true"
#    name                   = module.backend_alb.lb_dns_name
#    zone_id                = module.backend_alb.lb_zone_id
#  }
#}

module "beacon" {
  source       = "./route53"
  for_each     = local.route
  zone_id      = each.value["zone_id"]
  route53_name = each.value["route53_name"]

  lb_dns_name = each.value["lb_dns_name"]
  lb_zone_id  = each.value["lb_zone_id"]
}
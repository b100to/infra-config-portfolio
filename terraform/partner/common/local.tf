locals {
  region = "ap-northeast-2"
  env    = regex(join("|", values(var.environment)), var.TFC_WORKSPACE_NAME)

  internal       = "acme.internal"
  postfix_hyphen = var.postfix_hyphen[local.env]
  postfix_slash  = var.postfix_slash[local.env]
  alb_env        = var.alb_env[local.env]
  route = {
    h_back_alpha = {
      zone_id      = data.aws_route53_zone.internal.zone_id
      route53_name = "am-back${local.postfix_hyphen}.${local.internal}"

      lb_dns_name = data.aws_lb.hm_back.dns_name
      lb_zone_id  = data.aws_lb.hm_back.zone_id
    },
    h_front_alpha = {
      zone_id      = data.aws_route53_zone.internal.zone_id
      route53_name = "am-front${local.postfix_hyphen}.${local.internal}"

      lb_dns_name = data.aws_lb.hm_front.dns_name
      lb_zone_id  = data.aws_lb.hm_front.zone_id
    }
  }
}

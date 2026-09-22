env              = "prod"
frontend_acm_arn = "arn:aws:acm:ap-northeast-2:222222222222:certificate/00000000-0000-4000-8000-000000000002"
backend_acm_arn  = "arn:aws:acm:ap-northeast-2:222222222222:certificate/00000000-0000-4000-8000-000000000005"
zone_id          = "Z0EXAMPLE0002"
zone_id_kr       = "Z0EXAMPLE0004"
zone_name        = "acmemall.example"
zone_name_kr     = "acme.example"
dns_records = {
  frontend = "t-prod"
  backend  = "t-apiv3"
}

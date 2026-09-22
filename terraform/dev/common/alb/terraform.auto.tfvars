env              = "dev"
frontend_acm_arn = "arn:aws:acm:ap-northeast-2:111111111111:certificate/00000000-0000-4000-8000-000000000015"
backend_acm_arn  = "arn:aws:acm:ap-northeast-2:111111111111:certificate/00000000-0000-4000-8000-000000000008"
zone_id          = "Z0EXAMPLE0001"
zone_name        = "acmemall-dev.example"
dns_records = {
  frontend = "t-alpha"
  backend  = "t-apiv3"
}

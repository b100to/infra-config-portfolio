env              = "stage"
frontend_acm_arn = "arn:aws:acm:ap-northeast-2:222222222222:certificate/00000000-0000-4000-8000-000000000002"
backend_acm_arn  = "arn:aws:acm:ap-northeast-2:222222222222:certificate/00000000-0000-4000-8000-000000000002"
zone_id          = "Z0EXAMPLE0002"
zone_name        = "acmemall.example"
dns_records = {
  frontend = "t-stage"
  backend  = "t-apiv3-stage"
}

module "s3_for_logs_frontend" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "acme-frontend-alb-access-logs-${var.env}"
  acl    = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs
  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = "infra"
  }
}

module "s3_for_logs_backend" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "acme-backend-alb-access-logs-${var.env}"
  acl    = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  tags = {
    Environment = var.env
    Terraform   = "true"
    Project     = "infra"
  }
}

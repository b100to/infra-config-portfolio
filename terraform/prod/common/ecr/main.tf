module "ecr" {
  source = "cloudposse/ecr/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  namespace = "acme"
  stage     = var.env
  for_each  = var.repos
  name      = each.value

  enable_lifecycle_policy = false
  delimiter               = "/"
  image_tag_mutability    = "MUTABLE"
}

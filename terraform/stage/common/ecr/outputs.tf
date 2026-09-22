output "ecr_urls" {
  value = {
    for k, v in module.ecr : k => v
  }
}

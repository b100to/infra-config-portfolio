output "security_group_default" {
  description = "The ID of default security group in acme vpc"
  value       = module.default.security_group_id
}

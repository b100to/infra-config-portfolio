output "frontend_arn" {
  value = module.frontend_alb.lb_arn
}

output "frontend_dns_name" {
  value = module.frontend_alb.lb_dns_name
}

output "frontend_target_group_arns" {
  value = module.frontend_alb.target_group_arns
}

output "frontend_target_group_names" {
  value = module.frontend_alb.target_group_names
}

output "gateway_target_group_arn" {
  value = aws_lb_target_group.internal.arn
}

#output "frontend_record_name" {
#  value = aws_route53_record.frontend.name
#}

output "backend_arn" {
  value = module.backend_alb.lb_arn
}

output "backend_dns_name" {
  value = module.backend_alb.lb_dns_name
}

output "backend_target_group_arns" {
  value = module.backend_alb.target_group_arns
}

output "backend_target_group_names" {
  value = module.backend_alb.target_group_names
}

#output "backend_record_name" {
#  value = aws_route53_record.backend.name
#}

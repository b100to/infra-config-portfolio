output "target_group_arn" {
  value = aws_alb_target_group.main.arn
}

#output "listener_arn" {
#  value = aws_alb_listener.https.arn
#}
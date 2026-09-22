output "security_group_ids" {
  description = "Security group ids of databases."
  value = {
    acme_db = aws_security_group.acme.id
    beacon_db  = aws_security_group.beacon.id
  }
}

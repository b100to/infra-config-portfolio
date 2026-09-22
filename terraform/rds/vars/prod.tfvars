member = {
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.01.0"
  instance_type  = "db.r5.large"

  backup_retention_period = 3

  db_port = 4306

}
profile  = "prod"
password = "REPLACE_ME"


member = {
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.01.0"
  instance_type  = "db.t3.small"

  backup_retention_period = 1

  db_port = 3306

}
profile  = "dev"
password = "REPLACE_ME"


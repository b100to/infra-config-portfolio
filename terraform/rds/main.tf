module "member_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 6.2.0"

  name           = "service-${local.env}"
  engine         = var.member.engine
  engine_version = var.member.engine_version

  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets                = data.terraform_remote_state.vpc.outputs.private_subnets
  allowed_cidr_blocks    = data.terraform_remote_state.vpc.outputs.database_allowed_cidr_blocks
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.member.id]

  iam_database_authentication_enabled = false
  create_random_password              = false
  master_password                     = var.password

  port = var.member.db_port

  instances = {
    1 = {
      instance_class      = var.member.instance_type
      publicly_accessible = true
    }
  }
  #autoscaling
  autoscaling_enabled      = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 2

  # encryption
  storage_encrypted = true
  kms_key_id        = data.aws_kms_key.rds.arn

  # DB subnet group name
  db_subnet_group_name = "service-${local.env}"

  # DB parameter group
  db_parameter_group_name         = aws_db_parameter_group.member.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.member_cluster.name

  # enhanced monitoring
  monitoring_interval    = 60
  iam_role_name          = "rds-mon-license-modelitoring-${local.env}"
  create_monitoring_role = true

  # logs & events
  enabled_cloudwatch_logs_exports = []

  # maintenance
  backup_retention_period      = var.member.backup_retention_period
  preferred_backup_window      = "19:07-19:37"
  preferred_maintenance_window = "sat:16:20-sat:16:50"
  apply_immediately            = true

  # Database Deletion Protection
  deletion_protection = true
  skip_final_snapshot = true

  # tags
  copy_tags_to_snapshot = true
  cluster_tags          = { Name = "service-cluster" }
  tags                  = local.tags
}
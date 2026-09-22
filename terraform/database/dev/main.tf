provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-2"

  acme_db_name = "acme"
  acme_db_port = "3306"

  beacon_db_name                = "acme-beacon-pg"
  beacon_db_port                = "5432"
  beacon_db_allowed_cidr_blocks = ["10.0.0.0/16"]

  tags = {
    Terraform          = "true"
    Environment        = "dev"
    TerraformWorkspace = "database"
  }
}

################################################################################
# RDS Aurora Module
################################################################################
module "acme_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 3.0"

  name           = local.acme_db_name
  engine         = var.engine
  engine_version = var.engine_version
  instance_type  = "db.t3.small"

  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets                = data.terraform_remote_state.vpc.outputs.intra_subnets
  allowed_cidr_blocks    = data.terraform_remote_state.vpc.outputs.database_allowed_cidr_blocks
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.acme.id]

  username                     = "admin"
  create_random_password       = false
  port                         = local.acme_db_port
  replica_count                = 1
  instances_parameters         = [{ instance_name = "acme-instance-1" }]
  performance_insights_enabled = true

  # encryption
  storage_encrypted = true
  kms_key_id        = data.aws_kms_key.rds.arn

  # DB subnet group name
  db_subnet_group_name = aws_db_subnet_group.acme.name

  # DB parameter group
  db_parameter_group_name         = aws_db_parameter_group.acme.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.acme_cluster.name

  # enhanced monitoring
  monitoring_interval    = 60
  iam_role_name          = "rds-monitoring-role"
  create_monitoring_role = true

  # logs & events
  enabled_cloudwatch_logs_exports = []

  # maintenance
  backup_retention_period      = 1
  preferred_backup_window      = "19:07-19:37"
  preferred_maintenance_window = "sat:16:20-sat:16:50"
  apply_immediately            = true

  # Database Deletion Protection
  deletion_protection = true
  skip_final_snapshot = true

  # tags
  copy_tags_to_snapshot = true
  cluster_tags          = { Name = "acme-aurora-cluster" }
  tags                  = local.tags
}

module "beacon_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 3.0"

  name           = local.beacon_db_name
  engine         = "aurora-postgresql"
  engine_version = "11.9"
  instance_type  = "db.t3.medium"

  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets                = data.terraform_remote_state.vpc.outputs.intra_subnets
  allowed_cidr_blocks    = local.beacon_db_allowed_cidr_blocks
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.beacon.id]

  username                     = "postgres"
  create_random_password       = false
  port                         = local.beacon_db_port
  replica_count                = 1
  instances_parameters         = [{ instance_name = "acme-beacon-pg-instance-1" }]
  performance_insights_enabled = true

  # encryption
  storage_encrypted = true
  kms_key_id        = data.aws_kms_key.rds.arn

  # DB subnet group name
  db_subnet_group_name = aws_db_subnet_group.acme.name

  # DB parameter group
  db_parameter_group_name         = "default.aurora-postgresql11"
  db_cluster_parameter_group_name = "default.aurora-postgresql11"

  # enhanced monitoring
  monitoring_interval    = 60
  iam_role_name          = "rds-monitoring-role"
  create_monitoring_role = false
  monitoring_role_arn    = module.acme_db.this_enhanced_monitoring_iam_role_arn

  # logs & events
  enabled_cloudwatch_logs_exports = []

  # maintenance
  backup_retention_period      = 7
  preferred_backup_window      = "14:06-14:36"
  preferred_maintenance_window = "fri:17:50-fri:18:20"
  apply_immediately            = true

  # Database Deletion Protection
  deletion_protection = false
  skip_final_snapshot = true

  # tags
  copy_tags_to_snapshot = true
  tags                  = local.tags
}

################################################################################
# Supporting Resources
################################################################################
data "aws_kms_key" "rds" {
  key_id = "alias/aws/rds"
}

resource "aws_security_group" "acme" {
  name        = "RDS"
  description = "RDS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(local.tags, {
    Name = "acme-rds"
  })
}

resource "aws_security_group_rule" "acme" {
  type              = "ingress"
  from_port         = local.acme_db_port
  to_port           = local.acme_db_port
  protocol          = "tcp"
  security_group_id = aws_security_group.acme.id
  cidr_blocks       = data.terraform_remote_state.vpc.outputs.database_allowed_cidr_blocks
}

resource "aws_security_group" "beacon" {
  name        = "acme-rds-pg"
  description = "RDS (PostgreSQL)"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(local.tags, {
    Name = "acme-rds-pg"
  })
}

resource "aws_security_group_rule" "beacon" {
  type              = "ingress"
  from_port         = local.beacon_db_port
  to_port           = local.beacon_db_port
  protocol          = "tcp"
  security_group_id = aws_security_group.beacon.id
  cidr_blocks       = local.beacon_db_allowed_cidr_blocks
}

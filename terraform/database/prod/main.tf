provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-2"

  acme_db_name = "acme-aurora"
  acme_db_port = "3306"

  beacon_db_name = "acme-beacon-pg"
  beacon_db_port = "5432"

  pg_db_name = "aurora-pg-cluster"
  pg_db_port = "5432"

  tags = {
    Terraform          = "true"
    Environment        = "prod"
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
  instance_type  = "db.r5.xlarge"

  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets                = data.terraform_remote_state.vpc.outputs.intra_subnets
  allowed_cidr_blocks    = data.terraform_remote_state.vpc.outputs.database_allowed_cidr_blocks
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.acme.id]

  username               = "admin"
  create_random_password = false
  port                   = local.acme_db_port
  replica_count          = 2

  instances_parameters = [
    { instance_name = "acme-aurora-instance-1" },
    {
      instance_name           = "acme-aurora-instance-1-ap-northeast-2c"
      instance_promotion_tier = 1
    }
  ]

  performance_insights_enabled = true

  # encryption
  storage_encrypted = true
  kms_key_id        = data.aws_kms_key.rds.arn

  # DB subnet group name
  db_subnet_group_name = aws_db_subnet_group.acme.name

  # DB parameter group
  db_parameter_group_name         = aws_db_parameter_group.acme_aurora.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.acme_aurora_cluster.name

  # enhanced monitoring
  monitoring_interval    = 60
  iam_role_name          = "rds-monitoring-role"
  create_monitoring_role = true

  # logs & events
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  # maintenance
  backup_retention_period      = 3
  preferred_backup_window      = "19:35-20:05"
  preferred_maintenance_window = "tue:20:10-tue:20:40"
  apply_immediately            = true

  # Database Deletion Protection
  deletion_protection = true
  skip_final_snapshot = true

  # tags
  copy_tags_to_snapshot = true
  tags                  = local.tags
}

module "beacon_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 3.0"

  name           = local.beacon_db_name
  engine         = "aurora-postgresql"
  engine_version = "11.9"
  instance_type  = "db.r5.large"

  vpc_id                 = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets                = data.terraform_remote_state.vpc.outputs.intra_subnets
  create_security_group  = false
  vpc_security_group_ids = [data.aws_security_group.default.id]

  username               = "postgres"
  create_random_password = false
  port                   = local.beacon_db_port
  replica_count          = 2

  instances_parameters = [
    {
      instance_name           = "acme-beacon-pg-instance-1"
      instance_promotion_tier = 2
    },
    {
      instance_name           = "acme-beacon-pg-instance-1-ap-northeast-2c"
      instance_promotion_tier = 1
    }
  ]

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
  preferred_backup_window      = "18:41-19:11"
  preferred_maintenance_window = "thu:13:20-thu:13:50"
  apply_immediately            = true

  # Database Deletion Protection
  deletion_protection = true
  skip_final_snapshot = true

  # tags
  copy_tags_to_snapshot = true
  tags                  = local.tags
}

module "pg_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 3.0"

  name           = local.pg_db_name
  engine         = "aurora-postgresql"
  engine_version = "11.9"
  instance_type  = "db.r5.large"

  vpc_id                = data.aws_vpc.legacy.id
  create_security_group = false

  vpc_security_group_ids = [
    data.aws_security_group.lagacy_default.id,
    data.aws_security_group.legacy_rds_office.id,
    data.aws_security_group.legacy_load_balancer_dev.id
  ]

  publicly_accessible = true

  username               = "postgres"
  create_random_password = false
  port                   = local.pg_db_port
  replica_count          = 2

  instances_parameters = [
    {
      instance_name = "aurora-pg-cluster-instance-1"
    },
    {
      instance_name           = "aurora-pg-cluster-instance-1-ap-northeast-2c"
      instance_promotion_tier = 1
    }
  ]

  performance_insights_enabled = true

  # encryption
  storage_encrypted = true
  kms_key_id        = data.aws_kms_key.rds.arn

  # DB subnet group name
  db_subnet_group_name = "default"

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
  preferred_backup_window      = "17:21-17:51"
  preferred_maintenance_window = "mon:16:13-mon:16:43"
  apply_immediately            = true

  # Database Deletion Protection
  deletion_protection = true
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

data "aws_security_group" "default" {
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  id     = "sg-0000000000000006"
}

resource "aws_security_group" "acme" {
  name        = "acme-rds"
  description = "acme-rds"
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

################################################################################
# Supporting Resources in Legacy VPC
################################################################################
data "aws_vpc" "legacy" {
  id = "vpc-00000001"
}

data "aws_security_group" "lagacy_default" {
  vpc_id = data.aws_vpc.legacy.id
  id     = "sg-00000001"
}

data "aws_security_group" "legacy_rds_office" {
  vpc_id = data.aws_vpc.legacy.id
  id     = "sg-0000000000000003"
}

data "aws_security_group" "legacy_load_balancer_dev" {
  vpc_id = data.aws_vpc.legacy.id
  id     = "sg-0000000000000002"
}

################################################################################
# RDS Subnet Groups
################################################################################
resource "aws_db_subnet_group" "acme" {
  name        = "acme"
  description = "acme infra"
  subnet_ids  = data.terraform_remote_state.vpc.outputs.intra_subnets

  tags = local.tags
}

################################################################################
# RDS Parameter Groups
################################################################################
resource "aws_db_parameter_group" "acme" {
  name        = "acme"
  description = "acme rds"
  family      = "mysql5.7"

  parameter {
    apply_method = "immediate"
    name         = "character_set_client"
    value        = "utf8"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_connection"
    value        = "utf8"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_database"
    value        = "utf8"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_filesystem"
    value        = "utf8"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_results"
    value        = "utf8"
  }
  parameter {
    apply_method = "immediate"
    name         = "character_set_server"
    value        = "utf8"
  }
  parameter {
    apply_method = "immediate"
    name         = "collation_connection"
    value        = "utf8_general_ci"
  }
  parameter {
    apply_method = "immediate"
    name         = "collation_server"
    value        = "utf8_general_ci"
  }
  parameter {
    apply_method = "pending-reboot"
    name         = "time_zone"
    value        = "asia/seoul"
  }

  tags = local.tags
}

resource "aws_db_parameter_group" "acme_aurora" {
  name        = "acme-aurora"
  description = "acme"
  family      = "aurora-mysql5.7"

  tags = local.tags
}

resource "aws_rds_cluster_parameter_group" "acme_aurora_cluster" {
  name        = "acme-aurora-cluster"
  description = "acme-aurora"
  family      = "aurora-mysql5.7"

  parameter {
    apply_method = "immediate"
    name         = "max_allowed_packet"
    value        = "67108864"
  }
  tags = local.tags
}

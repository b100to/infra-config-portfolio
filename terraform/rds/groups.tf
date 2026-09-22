################################################################################
# RDS Parameter Groups
################################################################################
resource "aws_db_parameter_group" "member" {
  name        = "service-${local.env}"
  description = "dev"
  family      = "aurora-mysql8.0"

  parameter {
    apply_method = "immediate"
    name         = "max_connections"
    value        = "4000"
  }

  tags = local.tags
}

resource "aws_rds_cluster_parameter_group" "member_cluster" {
  name        = "service-cluster-${local.env}"
  description = "dev"
  family      = "aurora-mysql8.0"

  parameter {
    apply_method = "immediate"
    name         = "max_connections"
    value        = "4000"
  }

  tags = local.tags
}
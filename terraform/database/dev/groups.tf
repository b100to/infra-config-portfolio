################################################################################
# RDS Subnet Groups
################################################################################
resource "aws_db_subnet_group" "acme" {
  name        = "acme"
  description = "acme"
  subnet_ids  = data.terraform_remote_state.vpc.outputs.intra_subnets

  tags = local.tags
}

################################################################################
# RDS Parameter Groups
################################################################################
resource "aws_db_parameter_group" "acme" {
  name        = "acme"
  description = "acme"
  family      = "aurora-mysql5.7"

  parameter {
    apply_method = "immediate"
    name         = "max_connections"
    value        = "4000"
  }

  tags = local.tags
}

resource "aws_rds_cluster_parameter_group" "acme_cluster" {
  name        = "acme-cluster"
  description = "acme-cluster"
  family      = "aurora-mysql5.7"

  parameter {
    apply_method = "immediate"
    name         = "max_connections"
    value        = "4000"
  }

  tags = local.tags
}

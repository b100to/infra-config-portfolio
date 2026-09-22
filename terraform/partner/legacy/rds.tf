data "aws_rds_cluster" "acmemall" {
  cluster_identifier = var.rds_cluster[local.env]
}

data "aws_security_group" "bastion" {
  name = "Bastion"
}

resource "aws_security_group" "member" {
  name        = "RDS-service-${local.env}"
  description = "RDS"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(local.tags, {
    Name = "member-rds"
  })
}

#stage
resource "aws_security_group_rule" "member" {
  count             = local.env != "dev" ? 1 : 0
  type              = "ingress"
  from_port         = var.member.db_port
  to_port           = var.member.db_port
  protocol          = "tcp"
  security_group_id = aws_security_group.member.id

  cidr_blocks = ["10.0.0.0/16"]

  lifecycle {
    create_before_destroy = true
  }
}
#dev prod
resource "aws_security_group_rule" "main" {
  count                    = local.env == "dev" ? 1 : 0
  type                     = "ingress"
  from_port                = var.member.db_port
  to_port                  = var.member.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.member.id
  source_security_group_id = data.aws_security_group.bastion.id

  lifecycle {
    create_before_destroy = true
  }
}
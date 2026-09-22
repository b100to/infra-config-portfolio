resource "aws_security_group" "sg_http" {
  name        = "${var.project_name}${local.postfix_hyphen}"
  description = "Spring Cloud Gateway"
  vpc_id      = local.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = local.api_gateway_container_port
    to_port     = local.api_gateway_container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = local.eureka_container_port
    to_port     = local.eureka_container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_security_group" "acme_user_sg" {
  name        = "acme-user-sg${local.postfix_hyphen}"
  description = "controls access to the ALB"
  vpc_id      = local.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = local.acme_user_container_port
    to_port     = local.acme_user_container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    security_groups = [aws_security_group.sg_http.id]
    protocol        = -1
    from_port       = 0
    to_port         = 0
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDS Port"
    protocol    = "tcp"
    from_port   = data.aws_rds_cluster.acmemall.port
    to_port     = data.aws_rds_cluster.acmemall.port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.tags
}
###################
# Security Groups
###################
module "acme_elb_company" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "acme-elb-company"
  description = "company and vpn"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = local.office_cidr_block
      description = "Company"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = local.office_cidr_block
      description = "Company"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "203.0.113.1/32"
      description = "legacy commerce platform dev server ip (acmemall-dev.example)"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "203.0.113.25/32"
      description = "DEVELOPMENT VPC"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "203.0.113.4/32"
      description = "DEVELOPMENT VPC"
    },
  ]

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    description = ""
    cidr_blocks = "0.0.0.0/0"
  }]

  tags = local.tags
}

module "acme_frontend" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "acme-frontend"
  description = "-"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = local.vpc_cidr_block
      description = ""
    },
    {
      protocol    = "tcp"
      from_port   = 7001
      to_port     = 7001
      cidr_blocks = local.vpc_cidr_block
      description = ""
    },
  ]

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = local.tags
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = local.vpc_id
  service_name = "com.amazonaws.ap-northeast-2.s3"
}

# It should be inside module.glue, but separately defined here due to following issue:
# https://github.com/terraform-aws-modules/terraform-aws-security-group/issues/158
resource "aws_security_group_rule" "glue_egress_prefix_list" {
  security_group_id = module.glue.security_group_id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "outbound to S3 vpc endpoint"
  prefix_list_ids   = [data.aws_vpc_endpoint.s3.prefix_list_id]
}

module "glue" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "acme-glue"
  description = "allows glue to rds and s3 endpoint"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_self = [{
    rule        = "all-tcp"
    description = ""
  }]

  # egress rules
  egress_with_self = [{
    rule        = "all-tcp"
    description = ""
  }]

  egress_with_source_security_group_id = [{
    rule                     = "mysql-tcp"
    source_security_group_id = data.terraform_remote_state.database.outputs.security_group_ids["acme_db"]
    description              = "mysql to acme-infra rds"
  }]

  tags = local.tags
}


# It should be inside module.athena, but separately defined here due to following issue:
# https://github.com/terraform-aws-modules/terraform-aws-security-group/issues/158
resource "aws_security_group_rule" "athena_egress_prefix_list" {
  security_group_id = module.athena.security_group_id
  type              = "egress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "outbound to S3 vpc endpoint"
  prefix_list_ids   = [data.aws_vpc_endpoint.s3.prefix_list_id]
}

module "athena" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "acme-athena"
  description = "security group for athena vpc interface endpoint"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_self = [{
    rule        = "all-tcp"
    description = ""
  }]

  # egress rules
  egress_with_self = [{
    rule        = "all-tcp"
    description = ""
  }]

  tags = local.tags
}

module "default" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "default"
  description = "default VPC security group"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = merge(local.tags, { Name = "acme-default" })
}

module "acme_backend" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "acme-backend"
  description = "acme backend"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = local.vpc_cidr_block
      description = ""
    },
    {
      protocol    = "tcp"
      from_port   = 7002
      to_port     = 7002
      cidr_blocks = local.vpc_cidr_block
      description = ""
    },
    {
      protocol    = "tcp"
      from_port   = 7000
      to_port     = 7000
      cidr_blocks = local.vpc_cidr_block
      description = ""
    },
  ]

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = local.tags
}

module "legacy_default" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "default"
  description = "default VPC security group"

  use_name_prefix = false

  vpc_id = "vpc-0000000000000001" // legacy vpc id

  # ingress rules
  ingress_with_self = [{
    rule        = "all-all"
    description = ""
  }]

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = merge(local.tags, { Name = "temp" })
}

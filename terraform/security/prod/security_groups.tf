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
  ingress_with_cidr_blocks = concat(
    [
      for rule in ["http-80-tcp", "https-443-tcp"] :
      {
        rule        = rule
        cidr_blocks = local.office_cidr_block
        description = "company and vpn"
      }
    ],
    [{
      rule        = "https-443-tcp"
      cidr_blocks = local.cs_cidr_block
      description = "acme CS NAT gateway"
    }],
    [
      for ip in local.dev_nat_public_ips :
      {
        rule        = "https-443-tcp"
        cidr_blocks = "${ip}/32"
        description = "DEV acme public NAT gateway"
      }
    ],
    [
      for ip in local.nat_public_ips :
      {
        rule        = "https-443-tcp"
        cidr_blocks = "${ip}/32"
        description = "PROD acme public NAT gateway"
      }
    ]
  )

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    description = ""
    cidr_blocks = "0.0.0.0/0"
  }]

  tags = local.tags
}

module "elb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "acme-elb"
  description = "elb"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = ""
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
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


module "acme_frontend" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "acme-frontend"
  description = "acme-frontend"

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


module "acme_backend" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "acme-backend"
  description = "acme-backend"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_cidr_blocks = concat([
    {
      rule        = "http-80-tcp"
      cidr_blocks = local.vpc_cidr_block
      description = ""
    }],
    [
      for port in [7000, 7002] :
      {
        protocol    = "tcp"
        from_port   = port
        to_port     = port
        cidr_blocks = local.vpc_cidr_block
        description = ""
      }
  ])

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

  ingress_with_source_security_group_id = [{
    rule                     = "all-tcp"
    source_security_group_id = local.redash_sg
    description              = ""
  }]

  # egress rules
  egress_with_self = [{
    rule        = "all-tcp"
    description = ""
  }]

  tags = local.tags
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

  ingress_with_source_security_group_id = [
    {
      rule                     = "all-tcp"
      source_security_group_id = local.airflow_sg
      description              = ""
    },
    {
      rule                     = "all-tcp"
      source_security_group_id = local.redash_sg
      description              = ""
    }
  ]

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

  tags = local.tags
}

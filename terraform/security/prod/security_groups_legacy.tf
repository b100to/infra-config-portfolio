##########################
# LEGACY Security Groups
##########################
module "legacy_rds_office" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "rds-office"
  description = "rds-office"

  use_name_prefix = false

  vpc_id = local.legacy_vpc_id

  # ingress rules
  ingress_with_cidr_blocks = concat(
    [
      for port in [5432, 3306] :
      {
        protocol    = "tcp"
        from_port   = port
        to_port     = port
        cidr_blocks = local.office_cidr_block
        description = "hq-office"
      }
    ]
  )

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = local.tags
}

module "legacy_rds_tableau" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "rds-tableau"
  description = "rds-tableau"

  use_name_prefix = false

  vpc_id = local.legacy_vpc_id

  # ingress rules
  ingress_with_cidr_blocks = [
    for cidr in [
      // ..????????
      "203.0.113.11/32",
      "203.0.113.23/32",
      "203.0.113.14/32",
      "203.0.113.24/32",
      "203.0.113.15/32",
      "203.0.113.22/32",
      "203.0.113.13/32",
      "203.0.113.12/32",
      "203.0.113.19/32",
      "203.0.113.20/32",
      "203.0.113.10/28",
      "203.0.113.18/32",
      "203.0.113.21/32",
      "203.0.113.16/32",
      "203.0.113.17/32"
    ] :
    {
      rule        = "mysql-tcp"
      cidr_blocks = cidr
      description = ""
    }
  ]

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = local.tags
}

module "legacy_load_balancer_dev" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "load-balancer-dev"
  description = "load-balancer-wizard-1 created on 2019-07-16T15:47:20.806+09:00"

  use_name_prefix = false

  vpc_id = local.legacy_vpc_id

  # ingress rules
  ingress_with_ipv6_cidr_blocks = [
    for rule in ["http-80-tcp", "https-443-tcp"] :
    {
      rule             = rule
      ipv6_cidr_blocks = "::/0"
      description      = ""
    }
  ]

  ingress_with_cidr_blocks = concat(
    [
      for rule in ["http-80-tcp", "https-443-tcp"] :
      {
        rule        = rule
        cidr_blocks = "0.0.0.0/0"
        description = ""
      }
    ],
    [{
      rule        = "ssh-tcp"
      cidr_blocks = "203.0.113.8/32" // ???
      description = ""
    }]
  )

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = local.tags
}

module "legacy_web_server" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "web-server"
  description = "launch-wizard-1 created 2019-07-04T17:01:27.412+09:00"

  use_name_prefix = false

  vpc_id = local.legacy_vpc_id

  # ingress rules
  ingress_with_cidr_blocks = concat(
    [
      for rule in ["http-80-tcp", "https-443-tcp"] :
      {
        rule        = rule
        cidr_blocks = "0.0.0.0/0"
        description = ""
      }
    ],
    [{
      rule        = "ssh-tcp"
      cidr_blocks = local.office_cidr_block
      description = "hq-office"
    }]
  )

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = local.tags
}

module "legacy_rds_default" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "default"
  description = "default VPC security group"

  use_name_prefix = false

  vpc_id = local.legacy_vpc_id

  # ingress rules
  ingress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
      cidr_blocks = "203.0.113.2/29"
      description = "codebuild"
    },
    {
      rule        = "mysql-tcp"
      cidr_blocks = local.office_cidr_block
      description = "hq-office"
    }
  ]

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.legacy_web_server.security_group_id
      description              = "web-server"
    },
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.legacy_web_server.security_group_id
      description              = "web-server"
    },
    {
      protocol                 = "tcp"
      from_port                = 6379
      to_port                  = 6379
      source_security_group_id = module.legacy_web_server.security_group_id
      description              = "web-server"
    }
  ]

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = merge(local.tags, { Name = "rds-default" })
}

provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-2"
  tags = {
    Terraform          = "true"
    Environment        = "dev"
    TerraformWorkspace = "network"
  }
  network_acl = {
    public_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        protocol    = -1
        from_port   = 0
        to_port     = 0
        cidr_block  = "0.0.0.0/0"
      },
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        protocol    = -1
        from_port   = 0
        to_port     = 0
        cidr_block  = "0.0.0.0/0"
      },
    ]
    private_inbound = [{
      rule_number = 100
      rule_action = "allow"
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_block  = "0.0.0.0/0"
    }]
    private_outbound = [{
      rule_number = 100
      rule_action = "allow"
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_block  = "0.0.0.0/0"
    }]
    intra_inbound = [{
      rule_number = 100
      rule_action = "allow"
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_block  = "10.0.0.0/16"
    }]
    intra_outbound = [{
      rule_number = 100
      rule_action = "allow"
      protocol    = -1
      from_port   = 0
      to_port     = 0
      cidr_block  = "10.0.0.0/16"
    }]
  }
}

################################################################################
# VPC Module
################################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.cidr

  azs             = ["${local.region}a", "${local.region}c"]
  private_subnets = var.private_subnets
  intra_subnets   = var.intra_subnets
  public_subnets  = var.public_subnets

  enable_dns_hostnames = true

  # nat gateway
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # dhcp
  enable_dhcp_options               = true
  dhcp_options_domain_name          = var.dhcp_options_domain_name
  dhcp_options_domain_name_servers  = var.dhcp_options_domain_name_servers
  dhcp_options_netbios_name_servers = []
  dhcp_options_netbios_node_type    = ""
  dhcp_options_ntp_servers          = []
  dhcp_options_tags                 = {}

  # network ACL
  public_dedicated_network_acl = true
  public_inbound_acl_rules     = local.network_acl.public_inbound
  public_outbound_acl_rules    = local.network_acl.public_outbound

  private_dedicated_network_acl = true
  private_inbound_acl_rules     = local.network_acl.private_inbound
  private_outbound_acl_rules    = local.network_acl.private_outbound

  intra_dedicated_network_acl = true
  intra_inbound_acl_rules     = local.network_acl.intra_inbound
  intra_outbound_acl_rules    = local.network_acl.intra_outbound

  tags = local.tags
}

################################################################################
# VPC Endpoints Module
################################################################################
module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      tags         = { Name = "S3 gateway endpoint - all" }
    },
    athena = {
      service             = "athena"
      private_dns_enabled = true
      security_group_ids  = [data.aws_security_group.acme-athena.id]
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "Athena interface endpoint - private a/c" }
    }
    glue = {
      service             = "glue"
      private_dns_enabled = true
      security_group_ids  = [data.aws_security_group.acme-glue.id]
      subnet_ids          = module.vpc.private_subnets
      tags                = { Name = "Glue interface endpoint - private a/c" }
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################
data "aws_security_group" "acme-athena" {
  name   = "acme-athena"
  vpc_id = module.vpc.vpc_id
}

data "aws_security_group" "acme-glue" {
  name   = "acme-glue"
  vpc_id = module.vpc.vpc_id
}

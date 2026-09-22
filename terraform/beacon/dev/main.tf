provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-2"

  account_id = data.aws_caller_identity.current.account_id

  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnets    = data.terraform_remote_state.vpc.outputs.public_subnets
  private_subnet_2c = data.terraform_remote_state.vpc.outputs.private_subnets[1]
  default_sg        = data.terraform_remote_state.security.outputs.security_group_default

  tags = {
    Terraform          = "true"
    Environment        = "dev"
    TerraformWorkspace = "beacon"
  }
}

data "aws_caller_identity" "current" {}

#######################
# Supporting Resources
#######################
data "aws_acm_certificate" "acme_dev" {
  domain = "*.acme-dev.example"
}

resource "aws_network_interface" "beacon" {
  description = "Primary network interface"

  subnet_id       = local.private_subnet_2c
  security_groups = [local.default_sg]

  tags = merge(local.tags, { Name = "acme-beacon" })
}

resource "aws_ebs_volume" "beacon" {
  availability_zone = "ap-northeast-2c"
  size              = 8

  tags = merge(local.tags, { Name = "acme-beacon" })
}

resource "aws_volume_attachment" "beacon" {
  device_name = "/dev/xvda"
  volume_id   = aws_ebs_volume.beacon.id
  instance_id = module.beacon_ec2.id[0]
}

###############
# EC2 Instance
###############
module "beacon_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "beacon"
  instance_count = 1

  ami           = "ami-00000000000000001" # ami is deleted
  instance_type = "t2.micro"
  key_name      = "acme-internal"

  vpc_security_group_ids = [local.default_sg]
  subnet_id              = local.private_subnet_2c

  monitoring              = false
  disable_api_termination = false

  volume_tags = local.tags

  tags = merge(local.tags, { Name = "acme-beacon" })
}

#################
# Load Balancing
#################
module "beacon_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "acme-beacon-elb"

  load_balancer_type = "application"

  vpc_id          = local.vpc_id
  subnets         = local.public_subnets
  security_groups = [local.default_sg]

  target_groups = [
    {
      name             = "acme-beacon-route"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = module.beacon_ec2.id[0]
          port      = 80
        }
      ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:acm:ap-northeast-2:${local.account_id}:certificate/00000000-0000-4000-8000-000000000008"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = local.tags
}
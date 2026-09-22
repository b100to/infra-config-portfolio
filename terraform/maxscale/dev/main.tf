provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-2"

  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr_block    = data.terraform_remote_state.vpc.outputs.vpc_cidr_block
  private_subnet_2a = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  office_cidr_block = "203.0.113.7/32"

  tags = {
    Terraform          = "true"
    Environment        = "dev"
    TerraformWorkspace = "maxscale"
  }
}

#######################
# Supporting Resources
#######################
data "aws_ami" "aws_ubuntu" {
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20201026"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "maxscale_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "Maxscale"
  description = "maxscale"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = local.vpc_cidr_block
      description = ""
    },
    {
      protocol    = "tcp"
      from_port   = 4306
      to_port     = 4306
      cidr_blocks = local.vpc_cidr_block
      description = ""
    },
  ]

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-tcp"
    cidr_blocks = local.vpc_cidr_block
    description = ""
  }]

  tags = merge(local.tags, {
    Name = "acme-maxscale"
  })
}

resource "aws_network_interface" "maxscale" {
  description = "Primary network interface"

  subnet_id       = local.private_subnet_2a
  security_groups = [module.maxscale_sg.security_group_id]

  tags = local.tags
}

resource "aws_ebs_volume" "maxscale" {
  availability_zone = "ap-northeast-2a"
  size              = 8

  tags = merge(local.tags, { Name = "maxscale" })
}

resource "aws_volume_attachment" "maxscale" {
  device_name = "/dev/sda1"
  volume_id   = aws_ebs_volume.maxscale.id
  instance_id = module.maxscale.id[0]
}

######################
# EC2 Instance module
######################
module "maxscale" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "maxscale"
  instance_count = 1

  ami           = data.aws_ami.aws_ubuntu.image_id
  instance_type = "t2.micro"
  key_name      = "acme-internal"

  vpc_security_group_ids = [module.maxscale_sg.security_group_id]
  subnet_id              = local.private_subnet_2a

  monitoring              = false
  disable_api_termination = true

  volume_tags = local.tags

  tags = merge(local.tags, { Name = "acme-maxscale" })
}

provider "aws" {
  region = local.region
}

locals {
  region = "ap-northeast-2"

  vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_2a  = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  office_cidr_block = "203.0.113.7/32"

  tags = {
    Terraform          = "true"
    Environment        = "prod"
    TerraformWorkspace = "bastion"
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

module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.2"

  name        = "Bastion"
  description = "bastion"

  use_name_prefix = false

  vpc_id = local.vpc_id

  # ingress rules
  ingress_with_cidr_blocks = [{
    rule        = "ssh-tcp"
    cidr_blocks = local.office_cidr_block
    description = "Company"
  }]

  # egress rules
  egress_with_cidr_blocks = [{
    rule        = "all-all"
    cidr_blocks = "0.0.0.0/0"
    description = ""
  }]

  tags = merge(local.tags, { Name = "acme-bastion" })
}

resource "aws_eip" "bastion" {
  instance = module.bastion.id[0]
  vpc      = true

  tags = merge(local.tags, { Name = "acme-bastion" })
}

resource "aws_network_interface" "bastion" {
  description = "Primary network interface"

  subnet_id       = local.public_subnet_2a
  security_groups = [module.bastion_sg.security_group_id]

  tags = local.tags
}

resource "aws_ebs_volume" "bastion" {
  availability_zone = "ap-northeast-2a"
  size              = 8

  tags = merge(local.tags, { Name = "bastion" })
}

resource "aws_volume_attachment" "bastion" {
  device_name = "/dev/sda1"
  volume_id   = aws_ebs_volume.bastion.id
  instance_id = module.bastion.id[0]
}

######################
# EC2 Instance module
######################
module "bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = "bastion"
  instance_count = 1

  ami           = data.aws_ami.aws_ubuntu.image_id
  instance_type = "t2.micro"
  key_name      = "acme-bastion"

  vpc_security_group_ids = [module.bastion_sg.security_group_id]
  subnet_id              = local.public_subnet_2a

  monitoring              = false
  disable_api_termination = true

  volume_tags = local.tags

  tags = merge(local.tags, { Name = "acme-bastion" })
}

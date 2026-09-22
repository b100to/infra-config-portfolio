locals {
  env = regex(join("|", values(var.environment)), terraform.workspace)

  region     = "ap-northeast-2"
  account_id = data.aws_caller_identity.current.account_id

  image_url_prefix = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"

  project_name = {
    dev   = "acme-cloud"
    stage = "acme-cloud-stage"
    prod  = "acme-cloud"
  }
  role = {
    task = {
      dev   = "CloudEcsTaskRole"
      stage = "CloudEcsTaskRole-stage"
      prod  = "CloudEcsTaskRole"
    }
    task_execution = {
      dev   = "CloudEcsTaskExecutionRole"
      stage = "CloudEcsTaskExecutionRole-stage"
      prod  = "CloudEcsTaskExecutionRole"
    }
  }

  remote_env = {
    dev   = "dev"
    stage = "prod"
    prod  = "prod"
  }

  ecs = {
    vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
    public_subnets  = data.terraform_remote_state.vpc.outputs.public_subnets
    private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets

    cluster = data.aws_ecs_cluster.this.cluster_name
    cpu = {
      dev   = 512
      stage = 512
      prod  = 512
    }
    memory = {
      dev   = 1024
      stage = 1024
      prod  = 1024
    }
    name = {
      dev   = "partner-back-v2"
      stage = "partner-back-v2-stage"
      prod  = "partner-back-v2"
    }
    container_port     = 8080
    task_role_arn      = data.aws_iam_role.task.arn
    execution_role_arn = data.aws_iam_role.TaskExecution.arn
    desired_count = {
      dev   = 1
      stage = 1
      prod  = 1
    }
    image_name = {
      dev   = "cloud/partner/back-v2"
      stage = "cloud/partner/back-v2/stage"
      prod  = "cloud/partner/back-v2"
    }
    fluentbit_image_url = "${local.image_url_prefix}/fluentbit"


    zone_name         = data.aws_route53_zone.this.name
    zone_id           = data.aws_route53_zone.this.zone_id
    health_check_path = "/"

    dd_project = "partner"
    dd_service = "back-v2"
    dd_source  = "java"

    tags = {
      Terraform   = "true"
      Project     = "partner"
      Environment = local.env
    }
  }
}
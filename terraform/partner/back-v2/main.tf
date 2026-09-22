module "back-v2" {
  source = "../../modules/ecs/v2-ecs"

  ecs = {
    cluster = data.aws_ecs_cluster.this.cluster_name

    vpc_id          = local.ecs.vpc_id
    public_subnets  = local.ecs.public_subnets
    private_subnets = local.ecs.private_subnets

    image_name          = local.ecs.image_name[local.env]
    fluentbit_image_url = local.ecs.fluentbit_image_url

    name              = local.ecs.name[local.env]
    container_port    = local.ecs.container_port
    health_check_path = local.ecs.health_check_path
    desired_count     = local.ecs.desired_count[local.env]
    cpu               = local.ecs.cpu[local.env]
    memory            = local.ecs.memory[local.env]


    task_role_arn      = local.ecs.task_role_arn
    execution_role_arn = local.ecs.execution_role_arn

    zone_name = data.aws_route53_zone.this.name
    zone_id   = data.aws_route53_zone.this.zone_id

    dd_env     = local.env
    dd_project = local.ecs.dd_project
    dd_service = local.ecs.dd_service
    dd_source  = local.ecs.dd_source

    tags = local.ecs.tags
  }
}

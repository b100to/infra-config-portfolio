variable "ecs" {
  type = object({
    vpc_id          = string
    public_subnets  = list(string)
    private_subnets = list(string)

    cluster = string
    cpu     = number
    memory  = number

    name                = string
    container_port      = number
    task_role_arn       = string
    execution_role_arn  = string
    desired_count       = number
    image_name          = string
    fluentbit_image_url = string

    zone_name         = string
    zone_id           = string
    health_check_path = string

    dd_project = string
    dd_service = string
    dd_source  = string
    dd_env     = string

    tags = map(string)
  })
}
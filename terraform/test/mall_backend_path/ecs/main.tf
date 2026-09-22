resource "aws_ecs_service" "back_mall" {
  name    = "service-am-backend-alpha2"
  cluster = "acmemall-alpha"

  task_definition = data.aws_ecs_task_definition.back_mall.id
  desired_count   = 1
  launch_type     = "FARGATE"

  enable_execute_command = true

  health_check_grace_period_seconds  = 120
  force_new_deployment               = true
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    security_groups = [data.aws_security_group.back_mall.id]
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.back_mall1.arn
    container_name   = "nginx"
    container_port   = 80
  }
}

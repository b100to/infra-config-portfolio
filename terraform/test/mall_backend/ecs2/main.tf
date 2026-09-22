data "aws_ecs_task_definition" "back_mall" {
  task_definition = "service-am-backend-alpha"
}

resource "aws_ecs_service" "back_test" {
  name            = "back-test"
  cluster         = local.ecs_cluster_name
  task_definition = data.aws_ecs_task_definition.back_mall.id
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = data.aws_lb_target_group.back_mall.arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
    security_groups = [data.aws_security_group.back_mall.id]

  }
}

resource "aws_ecs_service" "main" {
  name    = "gateway-test"
  cluster = "acme-cloud"

  task_definition = data.aws_ecs_task_definition.gateway.id
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = data.aws_alb_target_group.gateway.arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    security_groups = [data.aws_security_group.gateway.id]
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
  }
}


resource "aws_ecs_service" "beacon-ins" {
  name    = "test-beacon-scan"
  cluster = "acme-cloud"

  task_definition = data.aws_ecs_task_definition.beacon_ins.id
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = data.aws_alb_target_group.beacon_ins.arn
    container_name   = "cloud-beacon-scan"
    container_port   = 80
  }

  network_configuration {
    security_groups = [data.aws_security_group.beacon_ins.id]
    subnets         = data.terraform_remote_state.vpc.outputs.private_subnets
  }
}


resource "aws_ecr_repository" "main" {
  name = "test-spring-gateway-nginx"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ecs_cluster" "this" {
  cluster_name = var.ecs_cluster[local.env]
}

data "aws_caller_identity" "account" {}

data "aws_iam_role" "task" {
  name = "acmeBackendEcsTaskRole"
}

data "aws_iam_role" "TaskExecution" {
  name = "ecsTaskExecutionRole"
}

data "aws_ecs_task_definition" "backend_mall" {
  task_definition = "service-am-backend-alpha"
}

data "aws_route53_zone" "external" {
  name = "acme-dev.example"
}

data "aws_lb_target_group" "back_mall" {
  name = "back-tg-mall"
}

data "aws_security_group" "front_mall" {
  filter {
    name   = "group-name"
    values = ["am-backend-ecs-sg"]
  }
}
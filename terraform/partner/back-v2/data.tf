data "aws_caller_identity" "current" {}

data "aws_ecs_cluster" "this" {
  cluster_name = local.project_name[local.env]
}

data "aws_route53_zone" "this" {
  name         = "acme.internal"
  private_zone = true
}

data "aws_iam_role" "task" {
  name = local.role.task[local.env]
}

data "aws_iam_role" "TaskExecution" {
  name = local.role.task_execution[local.env]
}



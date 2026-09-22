data "aws_ecs_task_definition" "back_mall" {
  task_definition = "service-am-backend-alpha1"
}

data "aws_lb_target_group" "back_mall1" {
  name = "mall-backend-tg-dev"
}

data "aws_lb_target_group" "this" {
  name = "tg-am-backend-alpha-ecs"
}

data "aws_security_group" "back_mall" {
  filter {
    name   = "group-name"
    values = ["am-backend-ecs-sg"]
  }
}
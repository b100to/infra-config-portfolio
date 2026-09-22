locals {
  ecs_cluster_name       = "acmemall-alpha"
  back_lb_name           = "back-alb"
  back_mall_target_group = "back-tg-mall"
}

data "aws_ecs_cluster" "alpha" {
  cluster_name = local.ecs_cluster_name
}

data "aws_lb" "back" {
  name = local.back_lb_name
}

data "aws_lb_target_group" "back_mall" {
  name = local.back_mall_target_group
}

data "aws_security_group" "back_mall" {
  filter {
    name   = "group-name"
    values = ["am-backend-ecs-sg"]
  }
}

data "aws_ecs_task_definition" "gateway" {
  task_definition = "test-spring-gateway"
}

data "aws_alb_target_group" "gateway" {
  name = "back-tg-h"
}

data "aws_security_group" "gateway" {
  filter {
    name   = "group-name"
    values = ["gateway"]
  }
}

data "aws_ecs_task_definition" "beacon_ins" {
  task_definition = "cloud-beacon-scan"
}

data "aws_alb_target_group" "beacon_ins" {
  name = "back-tg-beacon-ins"
}

data "aws_security_group" "beacon_ins" {
  filter {
    name   = "group-name"
    values = ["cloud-beacon-scan00000000000000000000000001"]
  }
}
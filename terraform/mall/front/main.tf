data "aws_ecs_cluster" "this" {
  cluster_name = "acmemall-alpha"
}

data "aws_ecs_service" "this" {
  cluster_arn  = data.aws_ecs_cluster.this.arn
  service_name = "service-am-front-alpha"
}

data "aws_security_group" "this" {
  name = "am-elb-default-sg"
}

resource "aws_lb" "this" {
  name = "elb-am-front-alpha-ecs"

  security_groups = [
    data.aws_security_group.this.id,
  ]

  subnets = local.private_subnets
}

data "aws_lb_target_group" "this" {
  arn = "arn:aws:elasticloadbalancing:${local.region}:${local.account_id}:targetgroup/tg-am-front-alpha-ecs/0000000000000000"
}

data "aws_route53_zone" "this" {
  name         = var.internal_dns
  private_zone = true
}

resource "aws_route53_record" "this" {
  name    = "am-front.${data.aws_route53_zone.this.name}"
  type    = "A"
  zone_id = data.aws_route53_zone.this.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.this.arn
  }
}

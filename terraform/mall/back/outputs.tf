output "cluster" {
  value = data.aws_ecs_cluster.this.cluster_name
}

output "service" {
  value = data.aws_ecs_service.this.arn
}
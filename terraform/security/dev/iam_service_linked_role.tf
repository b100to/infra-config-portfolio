# ECS
resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}

resource "aws_iam_service_linked_role" "ecs_autoscaling" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
}

# Elasticache
resource "aws_iam_service_linked_role" "elasticache" {
  aws_service_name = "elasticache.amazonaws.com"
  description      = "This policy allows ElastiCache to manage AWS resources on your behalf as necessary for managing your cache."
}

# ELB
resource "aws_iam_service_linked_role" "elb" {
  aws_service_name = "elasticloadbalancing.amazonaws.com"
  description      = "Allows ELB to call AWS services on your behalf."
}

# Kafka
resource "aws_iam_service_linked_role" "kafka" {
  aws_service_name = "kafka.amazonaws.com"
}

# Lambda
resource "aws_iam_service_linked_role" "lambda_replicator" {
  aws_service_name = "replicator.lambda.amazonaws.com"
}

# Organizations
resource "aws_iam_service_linked_role" "organizations" {
  aws_service_name = "organizations.amazonaws.com"
  description      = "Service-linked role used by AWS Organizations to enable integration of other AWS services with Organizations."
}

# RDS
resource "aws_iam_service_linked_role" "rds" {
  aws_service_name = "rds.amazonaws.com"
  description      = "Allows Amazon RDS to manage AWS resources on your behalf"
}

# SSM
resource "aws_iam_service_linked_role" "ssm" {
  aws_service_name = "ssm.amazonaws.com"
  description      = "Provides access to AWS Resources managed or used by Amazon SSM."
}

# Support
resource "aws_iam_service_linked_role" "support" {
  aws_service_name = "support.amazonaws.com"
  description      = "Enables resource access for AWS to provide billing, administrative and support services"
}

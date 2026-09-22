# Autoscaling
resource "aws_iam_service_linked_role" "autoscaling" {
  aws_service_name = "autoscaling.amazonaws.com"
  description      = "Default Service-Linked Role enables access to AWS Services and Resources used or managed by Auto Scaling"
}

# CloudFront
resource "aws_iam_service_linked_role" "cloudfront_logger" {
  aws_service_name = "logger.cloudfront.amazonaws.com"
}

# DynamoDB
resource "aws_iam_service_linked_role" "dynamodb_autoscaling" {
  aws_service_name = "dynamodb.application-autoscaling.amazonaws.com"
}

# ECS
resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
  description      = "Role to enable Amazon ECS to manage your cluster."
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

# Global Accelerator
resource "aws_iam_service_linked_role" "global_accelerator" {
  aws_service_name = "globalaccelerator.amazonaws.com"
  description      = "Allows Global Accelerator to call AWS services on customer's behalf"
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

# Support
resource "aws_iam_service_linked_role" "support" {
  aws_service_name = "support.amazonaws.com"
  description      = "Enables resource access for AWS to provide billing, administrative and support services"
}

# Trusted Advisor
resource "aws_iam_service_linked_role" "trustedadvisor" {
  aws_service_name = "trustedadvisor.amazonaws.com"
  description      = "Access for the AWS Trusted Advisor Service to help reduce cost, increase performance, and improve security of your AWS environment."
}

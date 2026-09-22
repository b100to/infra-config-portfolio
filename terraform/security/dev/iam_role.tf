################
# ECS IAM roles
################
resource "aws_iam_role" "ecs_autoscale" {
  name = "ecsAutoscaleRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale" {
  policy_arn = data.aws_iam_policy.amazon_ec2_container_service_autoscale.arn
  role       = aws_iam_role.ecs_autoscale.name
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  policy_arn = data.aws_iam_policy.amazon_ecs_task_execution_role.arn
  role       = aws_iam_role.ecs_task_execution.name
}

resource "aws_iam_role" "acme_backend_ecs_task_role" {
  name        = "acmeBackendEcsTaskRole"
  description = "Allows ECS tasks to call AWS services on your behalf."

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "acme_backend_ecs_task_role_1" {
  policy_arn = data.aws_iam_policy.secrets_manager_read_write.arn
  role       = aws_iam_role.acme_backend_ecs_task_role.name
}

resource "aws_iam_role_policy_attachment" "acme_backend_ecs_task_role_2" {
  policy_arn = data.aws_iam_policy.amazon_s3_full_access.arn
  role       = aws_iam_role.acme_backend_ecs_task_role.name
}

resource "aws_iam_role" "acme_frontend_ecs_task_role" {
  name        = "acmeFrontendEcsTaskRole"
  description = "Allows ECS tasks to call AWS services on your behalf."

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

################
# RDS IAM roles
################
resource "aws_iam_role" "rds_s3_export" {
  name = "rds-s3-export-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = "export.rds.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "rds_s3_export" {
  policy_arn = aws_iam_policy.export_rds_to_s3.arn
  role       = aws_iam_role.rds_s3_export.name
}

###################
# Lambda IAM roles
###################
resource "aws_iam_role" "lambda_image_optimizer" {
  name        = "LambdaImageOptimizer"
  description = "Allows Lambda functions to call AWS services on your behalf."

  # https://github.com/hashicorp/terraform-provider-aws/issues/11801
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_image_optimizer" {
  policy_arn = aws_iam_policy.lambda_image_optimizer.arn
  role       = aws_iam_role.lambda_image_optimizer.name
}

resource "aws_iam_role" "export_rds_to_s3_lambda_execution" {
  name        = "ExportRDStoS3LambdaExecutionRole"
  description = "Lambda execution role for exporting rds db snapshot to s3 as parquet."

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "ExportRDStoS3LambdaPolicy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Sid      = "",
          Effect   = "Allow",
          Action   = "iam:PassRole",
          Resource = "arn:aws:iam::${local.account_id}:role/rds-s3-export-role"
        },
        {
          Sid      = "",
          Effect   = "Allow",
          Action   = "rds:StartExportTask",
          Resource = "*"
        },
        {
          Sid    = "",
          Effect = "Allow",
          Action = [
            "glue:StartCrawler",
            "glue:UpdateCrawler"
          ],
          Resource = "*"
        }
      ]
    })
  }

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "export_rds_to_s3_lambda_execution_1" {
  policy_arn = data.aws_iam_policy.aws_lambda_basic_execution.arn
  role       = aws_iam_role.export_rds_to_s3_lambda_execution.name
}

resource "aws_iam_role_policy_attachment" "export_rds_to_s3_lambda_execution_2" {
  policy_arn = data.aws_iam_policy.aws_lambda_eni_management_access.arn
  role       = aws_iam_role.export_rds_to_s3_lambda_execution.name
}

resource "aws_iam_role" "maintenance" {
  name = "maintenance-role-00000000"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "maintenance" {
  policy_arn = aws_iam_policy.aws_lambda_basic_execution.arn
  role       = aws_iam_role.maintenance.name
}

#############################
# Elasticbeanstalk IAM roles
#############################
resource "aws_iam_role" "elasticbeanstalk" {
  name = "aws-elasticbeanstalk-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "sts:ExternalId" : "elasticbeanstalk"
          }
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_1" {
  policy_arn = data.aws_iam_policy.aws_elasticbeanstalk_enhanced_health.arn
  role       = aws_iam_role.elasticbeanstalk.name
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_2" {
  policy_arn = data.aws_iam_policy.aws_elasticbeanstalk_service.arn
  role       = aws_iam_role.elasticbeanstalk.name
}

resource "aws_iam_role" "elasticbeanstalk_ec2" {
  name = "aws-elasticbeanstalk-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_ec2_1" {
  policy_arn = data.aws_iam_policy.aws_elasticbeanstalk_multicontainer_docker.arn
  role       = aws_iam_role.elasticbeanstalk_ec2.name
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_ec2_2" {
  policy_arn = data.aws_iam_policy.aws_elasticbeanstalk_web_tier.arn
  role       = aws_iam_role.elasticbeanstalk_ec2.name
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_ec2_3" {
  policy_arn = data.aws_iam_policy.aws_elasticbeanstalk_worker_tier.arn
  role       = aws_iam_role.elasticbeanstalk_ec2.name
}

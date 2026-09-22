################
# ECS IAM roles
################
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "acme_frontend_ecs_task" {
  name        = "acmeFrontendEcsTaskRole"
  description = "Allows ECS tasks to call AWS services on your behalf."

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = local.tags
}

resource "aws_iam_role" "acme_backend_ecs_task" {
  name        = "acmeBackendEcsTaskRole"
  description = "Allows ECS tasks to call AWS services on your behalf."

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "acme_backend_ecs_task_1" {
  policy_arn = data.aws_iam_policy.secrets_manager_readwrite.arn
  role       = aws_iam_role.acme_backend_ecs_task.name
}

resource "aws_iam_role_policy_attachment" "acme_backend_ecs_task_2" {
  policy_arn = data.aws_iam_policy.amazon_s3_full_access.arn
  role       = aws_iam_role.acme_backend_ecs_task.name
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  policy_arn = data.aws_iam_policy.amazon_ecs_task_execution_role_policy.arn
  role       = aws_iam_role.ecs_task_execution.name
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
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_call_to_sentinel" {
  name = "call-to-sentinel-role-00000000"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_call_to_sentinel" {
  policy_arn = aws_iam_policy.lambda_basic_execution_role["call_to_sentinel"].arn
  role       = aws_iam_role.lambda_call_to_sentinel.name
}

resource "aws_iam_role" "lambda_call_data_loader" {
  name = "call_data_loader-role-00000000"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_call_data_loader" {
  policy_arn = aws_iam_policy.lambda_basic_execution_role["call_data_loader"].arn
  role       = aws_iam_role.lambda_call_data_loader.name
}

resource "aws_iam_role" "lambda_call_reserve_push" {
  name = "call_reserve_push-role-00000000"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_call_reserve_push" {
  policy_arn = aws_iam_policy.lambda_basic_execution_role["call_reserve_push"].arn
  role       = aws_iam_role.lambda_call_reserve_push.name
}

resource "aws_iam_role" "lambda_maintenance" {
  name = "maintenance-role-00000000"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_maintenance" {
  policy_arn = aws_iam_policy.lambda_basic_execution_role["maintenance"].arn
  role       = aws_iam_role.lambda_maintenance.name
}

resource "aws_iam_role" "lambda_slack_to_sentry_channel" {
  name = "slack-to-sentry-channel-role-00000000"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_slack_to_sentry_channel" {
  policy_arn = aws_iam_policy.lambda_basic_execution_role["slack_to_sentry_channel"].arn
  role       = aws_iam_role.lambda_slack_to_sentry_channel.name
}

resource "aws_iam_role" "lambda_cloudfront_image_notfound_redirect" {
  name = "cloudfront-image-notfound-redirect-role-00000000"
  path = "/service-role/"

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

resource "aws_iam_role_policy_attachment" "lambda_cloudfront_image_notfound_redirect" {
  policy_arn = aws_iam_policy.lambda_basic_execution_role_cloudfront_image_notfound_redirect.arn
  role       = aws_iam_role.lambda_cloudfront_image_notfound_redirect.name
}

resource "aws_iam_role" "lambda_modify_images" {
  name = "modify-images-role-00000000"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_modify_images" {
  policy_arn = aws_iam_policy.lambda_basic_execution_role_modify_images.arn
  role       = aws_iam_role.lambda_modify_images.name
}

resource "aws_iam_role" "lambda_export_rds_to_s3" {
  name        = "ExportRDStoS3LambdaExecutionRole"
  description = "Lambda execution role for exporting rds db snapshot to s3 as parquet."

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

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

resource "aws_iam_role_policy_attachment" "lambda_export_rds_to_s3_1" {
  policy_arn = data.aws_iam_policy.aws_lambda_basic_execution_role.arn
  role       = aws_iam_role.lambda_export_rds_to_s3.name
}

resource "aws_iam_role_policy_attachment" "lambda_export_rds_to_s3_2" {
  policy_arn = data.aws_iam_policy.aws_lambda_eni_management_access.arn
  role       = aws_iam_role.lambda_export_rds_to_s3.name
}

#####################################
# Cognito IAM roles (when to use???)
#####################################
data "aws_iam_policy_document" "cognito_identity_assume_role_auth" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = ["ap-northeast-2:00000000-0000-4000-8000-000000000009"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

data "aws_iam_policy_document" "cognito_identity_assume_role_unauth" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = ["ap-northeast-2:00000000-0000-4000-8000-000000000009"]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

data "aws_iam_policy_document" "cognito_inline_auth" {
  statement {
    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cognito_inline_unauth" {
  statement {
    sid = "VisualEditor0"
    actions = [
      "s3:PutAnalyticsConfiguration",
      "s3:PutAccelerateConfiguration",
      "s3:ReplicateTags",
      "s3:RestoreObject",
      "s3:CreateBucket",
      "cognito-sync:*",
      "s3:ReplicateObject",
      "s3:PutEncryptionConfiguration",
      "s3:GetBucketObjectLockConfiguration",
      "s3:AbortMultipartUpload",
      "s3:PutBucketTagging",
      "s3:PutLifecycleConfiguration",
      "s3:UpdateJobPriority",
      "s3:PutObjectTagging",
      "s3:PutBucketVersioning",
      "s3:GetObjectRetention",
      "s3:PutMetricsConfiguration",
      "s3:PutReplicationConfiguration",
      "s3:PutObjectVersionTagging",
      "s3:PutObjectLegalHold",
      "s3:UpdateJobStatus",
      "s3:PutBucketCORS",
      "s3:GetObjectLegalHold",
      "s3:PutInventoryConfiguration",
      "s3:PutObject",
      "s3:PutBucketNotification",
      "s3:PutBucketWebsite",
      "s3:PutBucketRequestPayment",
      "s3:PutObjectRetention",
      "s3:PutBucketLogging",
      "mobileanalytics:PutEvents",
      "s3:PutBucketObjectLockConfiguration",
      "s3:CreateJob",
      "s3:ReplicateDelete"
    ]
    resources = ["*"]
  }
}

// check real use
resource "aws_iam_role" "cognito_acme_auth" {
  name = "Cognito_acmeAuth_Role"

  assume_role_policy = data.aws_iam_policy_document.cognito_identity_assume_role_auth.json

  inline_policy {
    name   = "oneClick_Cognito_acmeAuth_Role_0000000000000"
    policy = data.aws_iam_policy_document.cognito_inline_auth.json
  }

  tags = local.tags
}

resource "aws_iam_role" "cognito_acme_unauth" {
  name = "Cognito_acmeUnauth_Role"

  assume_role_policy = data.aws_iam_policy_document.cognito_identity_assume_role_unauth.json

  inline_policy {
    name   = "oneClick_Cognito_acmeUnauth_Role_0000000000001"
    policy = data.aws_iam_policy_document.cognito_inline_unauth.json
  }

  tags = local.tags
}

##########################
# LakeFormation IAM roles
##########################
resource "aws_iam_role" "lakeformation_register_location_slr" {
  name        = "LakeFormationRegisterLocationSLR"
  description = "User-defined role for registering location to Lake Formation"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = [
            "lakeformation.amazonaws.com",
            "glue.amazonaws.com"
          ]
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "LakeFormationRegisterLocationSLR"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Sid      = "",
          Effect   = "Allow",
          Action   = "s3:ListBucket",
          Resource = "arn:aws:s3:::acme.datalake.prod"
        },
        {
          Sid    = "",
          Effect = "Allow",
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
          ],
          Resource = "arn:aws:s3:::acme.datalake.prod/*"
        }
      ]
    })
  }

  tags = local.tags
}

resource "aws_iam_role" "lakeformation_workflow" {
  name        = "LakeFormationWorkflowRole"
  description = "Allows Glue to call AWS services for LakeFormation workflow."

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "LakeFormationWorkflowRole"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Sid    = "",
          Effect = "Allow",
          Action = [
            "lakeformation:GrantPermissions",
            "lakeformation:GetDataAccess"
          ],
          Resource = "*"
        },
        {
          Sid      = "",
          Effect   = "Allow",
          Action   = "iam:PassRole",
          Resource = "arn:aws:iam::${local.account_id}:role/LakeFormationWorkflowRole"
        }
      ]
    })
  }

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lakeformation_workflow_1" {
  policy_arn = data.aws_iam_policy.amazon_s3_full_access.arn
  role       = aws_iam_role.lakeformation_workflow.name
}

resource "aws_iam_role_policy_attachment" "lakeformation_workflow_2" {
  policy_arn = data.aws_iam_policy.aws_glue_service_role.arn
  role       = aws_iam_role.lakeformation_workflow.name
}

resource "aws_iam_role_policy_attachment" "lakeformation_workflow_3" {
  policy_arn = data.aws_iam_policy.amazon_athena_full_access.arn
  role       = aws_iam_role.lakeformation_workflow.name
}

################
# DMS IAM roles
################
resource "aws_iam_role" "dms_vpc" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "dms_vpc" {
  policy_arn = data.aws_iam_policy.amazon_dms_vpc_management_role.arn
  role       = aws_iam_role.dms_vpc.name
}

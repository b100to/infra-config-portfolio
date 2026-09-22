locals {
  lambda_functions = {
    call_reserve_push = {
      name       = "call_reserve_push"
      identifier = "00000000-0000-4000-8000-000000000001"
    }
    call_data_loader = {
      name       = "call_data_loader"
      identifier = "00000000-0000-4000-8000-000000000003"
    }
    call_to_sentinel = {
      name       = "call-to-sentinel"
      identifier = "00000000-0000-4000-8000-000000000004"
    }
    maintenance = {
      name       = "maintenance"
      identifier = "00000000-0000-4000-8000-000000000006"
    }
    slack_to_sentry_channel = {
      name       = "slack-to-sentry-channel"
      identifier = "00000000-0000-4000-8000-000000000012"
    }
  }

  lambda_img_functions = {
    cloudfront_image_notfound_redirect = "00000000-0000-4000-8000-000000000010" // us-east-1
    modify_images                      = "00000000-0000-4000-8000-000000000011"
  }
}

##############################
# Acme managed IAM policies
##############################
resource "aws_iam_policy" "amazon_ecr_full_access" {
  name        = "AmazonECRFullAccess"
  description = "ecr full access made by amazon"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid    = "VisualEditor0",
          Effect = "Allow",
          Action = [
            "ecr:GetRegistryPolicy",
            "ecr:DescribeRegistry",
            "ecr:GetAuthorizationToken",
            "ecr:DeleteRegistryPolicy",
            "ecr:PutRegistryPolicy",
            "ecr:PutReplicationConfiguration"
          ],
          Resource = "*"
        },
        {
          Sid      = "VisualEditor1",
          Effect   = "Allow",
          Action   = "ecr:*",
          Resource = "arn:aws:ecr:*:${local.account_id}:repository/*"
        }
      ]
    }
  )

  tags = local.tags
}

resource "aws_iam_policy" "user_pass_role" {
  name        = "UserPassRole"
  description = "enables the data lake administrator to create and run workflows"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid      = "",
          Effect   = "Allow",
          Action   = "iam:PassRole",
          Resource = "arn:aws:iam::${local.account_id}:role/LakeFormationWorkflowRole"
        }
      ]
    }
  )

  tags = local.tags
}

resource "aws_iam_policy" "lakeformation_slr" {
  name        = "LakeFormationSLR"
  description = "grants the data lake administrator permission to create the Lake Formation service-linked role"

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid      = "",
          Effect   = "Allow",
          Action   = "iam:CreateServiceLinkedRole",
          Resource = "*",
          Condition = {
            StringEquals = {
              "iam:AWSServiceName" : [
                "lakeformation.amazonaws.com"
              ]
            }
          }
        },
        {
          Sid      = "",
          Effect   = "Allow",
          Action   = "iam:PutRolePolicy",
          Resource = "arn:aws:iam::${local.account_id}:role/aws-service-role/lakeformation.amazonaws.com/AWSServiceRoleForLakeFormationDataAccess"
        }
      ]
    }
  )

  tags = local.tags
}

// policies for lambda
resource "aws_iam_policy" "lambda_basic_execution_role" {
  for_each = local.lambda_functions

  name        = "AWSLambdaBasicExecutionRole-${each.value.identifier}"
  path        = "/service-role/"
  description = ""

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "logs:CreateLogGroup",
        Resource = "arn:aws:logs:ap-northeast-2:${local.account_id}:*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "arn:aws:logs:ap-northeast-2:${local.account_id}:log-group:/aws/lambda/${each.value.name}:*"
        ]
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "lambda_basic_execution_role_cloudfront_image_notfound_redirect" {
  name        = "AWSLambdaBasicExecutionRole-00000000-0000-4000-8000-000000000010"
  path        = "/service-role/"
  description = ""

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "iam:CreateServiceLinkedRole",
          "lambda:GetFunction",
          "lambda:EnableReplication",
          "cloudfront:UpdateDistribution",
          "s3:GetObject",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "lambda_basic_execution_role_modify_images" {
  name        = "AWSLambdaBasicExecutionRole-00000000-0000-4000-8000-000000000011"
  path        = "/service-role/"
  description = ""

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0",
        Effect = "Allow",
        Action = [
          "iam:CreateServiceLinkedRole",
          "lambda:GetFunction",
          "lambda:EnableReplication",
          "cloudfront:UpdateDistribution",
          "s3:GetObject",
          "s3:PutObject",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "export_rds_to_s3" {
  name        = "ExportRDSToS3"
  description = "Policy for exporting rds snapshot to s3 as parquet"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ExportRDStoS3",
        Effect = "Allow",
        Action = [
          "s3:PutObject*",
          "s3:ListBucket",
          "s3:GetObject*",
          "s3:DeleteObject*",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::acme.datalake.prod/*",
          "arn:aws:s3:::acme.datalake.prod"
        ]
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "airflow_s3_access" {
  name        = "airflow-s3-access"
  description = "Allows airflow IAM user to access S3 acme-airflow-prod bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucketVersions",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${local.airflow_s3_bucket}",
          "arn:aws:s3:::${local.datalake_s3_bucket}",
          "arn:aws:s3:::${local.airflow_s3_bucket}/*",
          "arn:aws:s3:::${local.datalake_s3_bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:DeleteObjectVersion",
          "s3:DeleteObject"
        ],
        Resource = "arn:aws:s3:::${local.airflow_s3_bucket}/*"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "redash_athena_access" {
  name        = "redash-athena-access"
  description = "Allows redash to access athena"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${local.datalake_s3_bucket}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:CreateBucket"
        ],
        Resource = [
          "arn:aws:s3:::${local.datalake_s3_bucket}"
        ]
      }
    ]
  })
}
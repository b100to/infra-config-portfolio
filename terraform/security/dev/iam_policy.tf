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
          "arn:aws:s3:::acme.datalake.dev/*",
          "arn:aws:s3:::acme.datalake.dev"
        ]
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "lambda_image_optimizer" {
  name = "lambda-image-optimizer"
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

resource "aws_iam_policy" "aws_lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole-00000000-0000-4000-8000-000000000013"
  path = "/service-role/"

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
          "arn:aws:logs:ap-northeast-2:${local.account_id}:log-group:/aws/lambda/maintenance:*"
        ]
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "airflow_s3_access" {
  name        = "airflow-s3-access"
  description = "Allows airflow IAM user to access S3 acme-airflow-dev bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucketVersions",
          "s3:ListBucket",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:PutObject*"
        ],
        Resource = [
          "arn:aws:s3:::${local.airflow_s3_bucket}",
          "arn:aws:s3:::${local.airflow_s3_bucket}/*",
          "arn:aws:s3:::acme.datalake.dev",
          "arn:aws:s3:::acme.datalake.dev/*",
          "arn:aws:s3:::amplitude-export-00000-test/*"
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

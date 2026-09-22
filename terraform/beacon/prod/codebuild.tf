####################
# Codebuild Project
####################
resource "aws_codebuild_project" "beacon" {
  name         = "acme-beacon-build"
  service_role = aws_iam_role.codebuild_acme_beacon.arn

  source {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = true
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  tags = local.tags
}

################################
# Codebuild IAM Role & Policies
################################
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "codebuild_base_policy" {
  name        = "CodeBuildBasePolicy-acme-beacon-build-ap-northeast-2"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Resource = [
          "arn:aws:logs:ap-northeast-2:${local.account_id}:log-group:/aws/codebuild/acme-beacon-build",
          "arn:aws:logs:ap-northeast-2:${local.account_id}:log-group:/aws/codebuild/acme-beacon-build:*"
        ],
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::codepipeline-ap-northeast-2-*"
        ],
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ],
        Resource = [
          "arn:aws:codebuild:ap-northeast-2:${local.account_id}:report-group/acme-beacon-build-*"
        ]
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role" "codebuild_acme_beacon" {
  name = "codebuild-acme-beacon-build-service-role"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "codebuild_acme_beacon_1" {
  policy_arn = aws_iam_policy.codebuild_base_policy.arn
  role       = aws_iam_role.codebuild_acme_beacon.name
}

resource "aws_iam_role_policy_attachment" "codebuild_acme_beacon_2" {
  policy_arn = data.aws_iam_policy.amazon_s3_full_access.arn
  role       = aws_iam_role.codebuild_acme_beacon.name
}

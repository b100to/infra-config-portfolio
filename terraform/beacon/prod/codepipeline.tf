#############################
# CodePipeline Configuration
#############################
resource "aws_codepipeline" "beacon" {
  name     = "acme-beacon-pipeline"
  role_arn = aws_iam_role.codepipeline_acme_beacon.arn

  artifact_store {
    location = module.codepipeline_artifact.s3_bucket_id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "Source"

      category  = "Source"
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"
      version   = "1"
      namespace = "SourceVariables"

      configuration = {
        ConnectionArn        = "arn:aws:codestar-connections:ap-northeast-2:${local.account_id}:connection/00000000-0000-4000-8000-000000000007"
        FullRepositoryId     = "AcmeCorp/acme-scan-apiserver"
        BranchName           = "master"
        OutputArtifactFormat = "CODE_ZIP"
      }

      output_artifacts = ["SourceArtifact"]
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"

      category  = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      version   = "1"
      namespace = "BuildVariables"

      configuration = {
        ProjectName = aws_codebuild_project.beacon.name
      }

      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
    }
  }

  stage {
    name = "Deploy"

    action {
      name = "Deploy"

      category  = "Deploy"
      owner     = "AWS"
      provider  = "CodeDeploy"
      version   = "1"
      namespace = "DeployVariables"

      configuration = {
        ApplicationName     = aws_codedeploy_app.beacon.name
        DeploymentGroupName = aws_codedeploy_deployment_group.beacon_cont.deployment_group_name
      }

      input_artifacts = ["BuildArtifact"]
    }

    action {
      name = "Deploy-Celery"

      category  = "Deploy"
      owner     = "AWS"
      provider  = "CodeDeploy"
      version   = "1"
      namespace = "DeployVariables2"

      configuration = {
        ApplicationName     = aws_codedeploy_app.beacon_celery.name
        DeploymentGroupName = aws_codedeploy_deployment_group.beacon_celery_cont.deployment_group_name
      }

      input_artifacts = ["BuildArtifact"]
    }
  }

  tags = local.tags
}

##############################
# CodePipeline Artifact Store
##############################
module "codepipeline_artifact" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 2.6.0"

  bucket        = local.codepipeline_artifact_s3_bucket
  acl           = null # conflicts with grant
  force_destroy = false

  grant = [{
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }]

  attach_public_policy = false
  attach_policy        = true
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "SSEAndSSLPolicy",
    Statement = [
      {
        Sid       = "DenyUnEncryptedObjectUploads",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:PutObject",
        Resource  = "arn:aws:s3:::${local.codepipeline_artifact_s3_bucket}/*",
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" : "aws:kms"
          }
        }
      },
      {
        Sid       = "DenyInsecureConnections",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource  = "arn:aws:s3:::${local.codepipeline_artifact_s3_bucket}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })

  tags = local.tags
}

###################################
# CodePipeline IAM Role & Policies
###################################
data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_service_role" {
  statement {
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
  statement {
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["codestar-connections:UseConnection"]
    resources = ["*"]
  }
  statement {
    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "opsworks:CreateDeployment",
      "opsworks:DescribeApps",
      "opsworks:DescribeCommands",
      "opsworks:DescribeDeployments",
      "opsworks:DescribeInstances",
      "opsworks:DescribeStacks",
      "opsworks:UpdateApp",
      "opsworks:UpdateStack"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "devicefarm:ListProjects",
      "devicefarm:ListDevicePools",
      "devicefarm:GetRun",
      "devicefarm:GetUpload",
      "devicefarm:CreateUpload",
      "devicefarm:ScheduleRun"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "servicecatalog:ListProvisioningArtifacts",
      "servicecatalog:CreateProvisioningArtifact",
      "servicecatalog:DescribeProvisioningArtifact",
      "servicecatalog:DeleteProvisioningArtifact",
      "servicecatalog:UpdateProduct"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["cloudformation:ValidateTemplate"]
    resources = ["*"]
  }
  statement {
    actions   = ["ecr:DescribeImages"]
    resources = ["*"]
  }
  statement {
    actions = [
      "states:DescribeExecution",
      "states:DescribeStateMachine",
      "states:StartExecution"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "codepipeline_service_role" {
  name        = "AWSCodePipelineServiceRole-ap-northeast-2-acme-beacon-pipeline"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodePipeline"

  policy = data.aws_iam_policy_document.codepipeline_service_role.json

  tags = local.tags
}

resource "aws_iam_role" "codepipeline_acme_beacon" {
  name = "AWSCodePipelineServiceRole-ap-northeast-2-acme-beacon-pipeline"
  path = "/service-role/"

  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "codepipeline_acme_beacon" {
  policy_arn = aws_iam_policy.codepipeline_service_role.arn
  role       = aws_iam_role.codepipeline_acme_beacon.name
}

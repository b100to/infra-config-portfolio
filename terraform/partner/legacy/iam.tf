resource "aws_iam_policy" "s3_access" {
  name        = "AccessStaticAcmemallS3${local.postfix_hyphen}"
  description = "Allow static.acmemall.example S3 bucket"
  path        = "/"
  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [{
        Action = [
          "s3:ListBucket*",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
          "s3:GetObject",
          "s3:PutObject*",
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::private.acmemall.${var.url[local.env]}",
          "arn:aws:s3:::private.acmemall.${var.url[local.env]}/*",
          "arn:aws:s3:::static.acmemall.${var.url[local.env]}",
          "arn:aws:s3:::static.acmemall.${var.url[local.env]}/*",
        ]
      }]
    }
  )
  tags = local.tags
}

resource "aws_iam_policy" "secret_manager_get_secret_value" {
  name        = "AccessSecretManager${local.postfix_hyphen}"
  description = "Allows ECS tasks to call AWS services on your behalf. "
  path        = "/"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : "secretsmanager:GetSecretValue",
          "Resource" : "arn:aws:secretsmanager:*:${local.account_id}:secret:*"
        }
      ]
    }
  )
  tags = local.tags
}

resource "aws_iam_role" "ecs_task" {
  name                = "CloudEcsTaskRole${local.postfix_hyphen}"
  description         = "Allows ECS tasks to call AWS services on your behalf."
  managed_policy_arns = [aws_iam_policy.s3_access.arn, aws_iam_policy.secret_manager_get_secret_value.arn]

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = local.tags
}

resource "aws_iam_role" "partner_front_ecs_task" {
  name        = "PartnerFrontEcsTaskRole${local.postfix_hyphen}"
  description = "Allows ECS tasks to call AWS services on your behalf."

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = local.tags
}

resource "aws_iam_role" "partner_back_ecs_task" {
  name                = "PartnerBackEcsTaskRole${local.postfix_hyphen}"
  description         = "Allows ECS tasks to call AWS services on your behalf."
  managed_policy_arns = [aws_iam_policy.s3_access.arn, data.aws_iam_policy.s3_full.arn]

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

resource "aws_iam_role" "acme_user_ecs_task" {
  name        = "AcmeUserBackEcsTaskRole${local.postfix_hyphen}"
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

resource "aws_iam_role" "ecs_task_execution" {
  name               = "CloudEcsTaskExecutionRole${local.postfix_hyphen}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  policy_arn = data.aws_iam_policy.amazon_ecs_task_execution_role_policy.arn
  role       = aws_iam_role.ecs_task_execution.name
}

resource "aws_iam_role_policy_attachment" "acme_backend_ecs_task_role_1" {
  policy_arn = data.aws_iam_policy.secrets_manager_read_write.arn
  role       = aws_iam_role.partner_front_ecs_task.name
}

resource "aws_iam_role_policy_attachment" "acme_backend_ecs_task_role_2" {
  policy_arn = data.aws_iam_policy.amazon_s3_full_access.arn
  role       = aws_iam_role.partner_back_ecs_task.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ecs-agent${local.postfix_hyphen}"
  role = aws_iam_role.ecs_task.name
}
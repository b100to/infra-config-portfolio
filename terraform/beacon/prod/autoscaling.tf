###################################
# AutoScaling Launch Configuration
###################################
module "beacon_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.4.0"

  create_asg = false
  create_lc  = true

  name = "acme-beacon-as"

  use_name_prefix    = false
  lc_use_name_prefix = false

  ebs_optimized     = false
  enable_monitoring = false

  image_id                  = "ami-00000000000000001"
  instance_type             = "t3.small"
  iam_instance_profile_name = aws_iam_instance_profile.codedeploy_instance_profile.arn

  key_name = "acme-internal"

  security_groups = [local.default_sg]
}

module "beacon_celery_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.4.0"

  create_asg = false
  create_lc  = true

  name = "acme-beacon-celery-as"

  use_name_prefix    = false
  lc_use_name_prefix = false

  ebs_optimized     = false
  enable_monitoring = false

  image_id                  = "ami-00000000000000001"
  instance_type             = "t3.xlarge"
  iam_instance_profile_name = aws_iam_instance_profile.codedeploy_instance_profile.arn

  key_name = "acme-internal"

  security_groups = [local.default_sg]
}

##################################
# IAM Instance Profile & Policies
##################################
resource "aws_iam_policy" "code_deploy_policy" {
  name        = "code-deploy-policy"
  description = ""

  policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Sid    = "VisualEditor0",
          Effect = "Allow",
          Action = [
            "ec2:DescribeInstances",
            "elasticloadbalancing:RegisterTargets",
            "autoscaling:DescribePolicies",
            "logs:*",
            "iam:RemoveRoleFromInstanceProfile",
            "iam:CreateRole",
            "iam:PutRolePolicy",
            "autoscaling:*",
            "iam:AddRoleToInstanceProfile",
            "autoscaling:PutScheduledUpdateGroupAction",
            "elasticloadbalancing:DescribeLoadBalancers",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:UpdateAutoScalingGroup",
            "autoscaling:DescribeNotificationConfigurations",
            "iam:ListRolePolicies",
            "elasticloadbalancing:DescribeInstanceHealth",
            "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
            "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
            "autoscaling:PutNotificationConfiguration",
            "iam:GetRole",
            "autoscaling:ResumeProcesses",
            "iam:DeleteRole",
            "elasticloadbalancing:DeregisterTargets",
            "autoscaling:SuspendProcesses",
            "cloudwatch:DescribeAlarms",
            "ecs:*",
            "ec2:*",
            "autoscaling:DeleteAutoScalingGroup",
            "autoscaling:DeleteLifecycleHook",
            "iam:GetRolePolicy",
            "autoscaling:CreateAutoScalingGroup",
            "autoscaling:RecordLifecycleActionHeartbeat",
            "iam:CreateInstanceProfile",
            "tag:GetResources",
            "iam:ListInstanceProfilesForRole",
            "iam:PassRole",
            "sns:Publish",
            "autoscaling:DescribeScalingActivities",
            "iam:DeleteRolePolicy",
            "autoscaling:PutScalingPolicy",
            "codedeploy:*",
            "autoscaling:DescribeScheduledActions",
            "ec2:DescribeInstanceStatus",
            "iam:DeleteInstanceProfile",
            "autoscaling:AttachLoadBalancers",
            "autoscaling:EnableMetricsCollection",
            "ec2:TerminateInstances",
            "iam:GetInstanceProfile",
            "s3:*",
            "autoscaling:PutLifecycleHook",
            "iam:ListRoles",
            "elasticloadbalancing:*",
            "autoscaling:DescribeLifecycleHooks",
            "cloudwatch:PutMetricAlarm",
            "autoscaling:CompleteLifecycleAction",
            "lambda:*",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:DescribeTargetGroups"
          ],
          Resource = "*"
        }
      ]
    }
  )

  tags = local.tags
}

resource "aws_iam_role" "codedeploy_policy" {
  name        = "code-deploy-policy"
  description = "drq delpoy IAM."

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
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

resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  policy_arn = aws_iam_policy.code_deploy_policy.arn
  role       = aws_iam_role.codedeploy_policy.name
}

resource "aws_iam_instance_profile" "codedeploy_instance_profile" {
  name = "code-deploy-policy"
  role = aws_iam_role.codedeploy_policy.name
}

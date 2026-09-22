#############################################
# Codedeploy App & Deployment Groups - beacon
#############################################
resource "aws_codedeploy_app" "beacon" {
  name = "acme-beacon-deploy"
  tags = local.tags
}

// check real use
resource "aws_codedeploy_deployment_group" "beacon_first" {
  app_name               = aws_codedeploy_app.beacon.name
  deployment_group_name  = "acme-beacon-deploy-first"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "acme-beacon-as-grp"
    }
  }

  load_balancer_info {
    target_group_info {
      name = module.beacon_alb.target_group_names[0]
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  tags = local.tags
}

resource "aws_codedeploy_deployment_group" "beacon_cont" {
  app_name               = aws_codedeploy_app.beacon.name
  deployment_group_name  = "acme-beacon-deploy-cont"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  autoscaling_groups = ["CodeDeploy_acme-beacon-deploy-cont_d-NQAU4HI7A"]

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_info {
      name = module.beacon_alb.target_group_names[0]
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  lifecycle {
    # ASG always changes per deployment in blue/green deployment type with COPY_AUTO_SCALING_GROUP option
    # See https://github.com/hashicorp/terraform-provider-aws/issues/4678
    ignore_changes = [autoscaling_groups]
  }

  tags = local.tags
}

####################################################
# Codedeploy App & Deployment Groups - beacon-celery
####################################################
resource "aws_codedeploy_app" "beacon_celery" {
  name = "acme-beacon-celery-deploy"
  tags = local.tags
}

// check real use
resource "aws_codedeploy_deployment_group" "beacon_celery_first" {
  app_name               = aws_codedeploy_app.beacon_celery.name
  deployment_group_name  = "acme-beacon-celery-deploy-first"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "acme-beacon-celery-as-grp"
    }
  }

  load_balancer_info {
    target_group_info {
      name = module.beacon_celery_alb.target_group_names[0]
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  tags = local.tags
}

resource "aws_codedeploy_deployment_group" "beacon_celery_cont" {
  app_name               = aws_codedeploy_app.beacon_celery.name
  deployment_group_name  = "acme-beacon-celery-deploy-cont"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  autoscaling_groups = ["CodeDeploy_acme-beacon-celery-deploy-cont_d-FLRDZ6I7A"]

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_info {
      name = module.beacon_celery_alb.target_group_names[0]
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  lifecycle {
    # ASG always changes per deployment in blue/green deployment type with COPY_AUTO_SCALING_GROUP option
    # See https://github.com/hashicorp/terraform-provider-aws/issues/4678
    ignore_changes = [autoscaling_groups]
  }

  tags = local.tags
}

#################################
# Codedeploy IAM role & policies
#################################
resource "aws_iam_role" "codedeploy_role" {
  name        = "code-deploy-role"
  description = "Allows CodeDeploy to call AWS services such as Auto Scaling on your behalf."

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "",
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_1" {
  policy_arn = data.aws_iam_policy.amazon_s3_full_access.arn
  role       = aws_iam_role.codedeploy_role.name
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_2" {
  policy_arn = data.aws_iam_policy.aws_codedeploy_role.arn
  role       = aws_iam_role.codedeploy_role.name
}

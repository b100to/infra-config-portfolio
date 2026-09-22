locals {
  users = {
    acmers = [
      "user01@acme-corp.example",
      "user04@acme-corp.example",
      "user05@acme-corp.example",
      "user10@acme-corp.example",
      "user12@acme-corp.example",
      "user15@acme-corp.example",
      "user20@acme-corp.example",
      "user21@acme-corp.example",
      "user22@acme-corp.example",
      "user25@acme-corp.example",
      #      "user28@acme-corp.example",
      #      "user03@acme-corp.example",
      #      "user02@acme-corp.example",
      "user06@acme-corp.example",
      "user07@acme-corp.example",
      "user08@acme-corp.example",
      "user09@acme-corp.example",
      "user11@acme-corp.example",
      "user13@acme-corp.example",
      "user14@acme-corp.example",
      "user16@acme-corp.example",
      "user17@acme-corp.example",
      "user18@acme-corp.example",
      "user19@acme-corp.example",
      "user23@acme-corp.example",
      "user24@acme-corp.example",
      "user26@acme-corp.example",
      "user27@acme-corp.example",
    ]

    system = [
      "deploy",
      "acme-terraform",
      "airflow",
      "acmemall-backend",
      "front-deploy",
      "redash",
    ]
  }
}

############
# IAM users
############
module "iam_user_acmers" {
  for_each = toset(local.users.acmers)

  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4.1"

  name = each.value

  ###################################################################################################
  # TODO: handle iam_user module with pgp_key
  # Although every human iam_users has login_profile (and might has access_key),
  # we do not manage them via terraform not yet because pgp_key is not prepared in our organization.
  ###################################################################################################
  create_iam_user_login_profile = false
  create_iam_access_key         = false

  tags = local.tags
}

module "iam_user_system" {
  for_each = toset(local.users.system)

  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4.1"

  name = each.value

  ###################################################################################################
  # TODO: handle iam_user module with pgp_key
  # Although every system iam_users has access_key (and no login_profile),
  # we do not manage them via terraform not yet because pgp_key is not prepared in our organization.
  ###################################################################################################
  create_iam_user_login_profile = false
  create_iam_access_key         = false

  tags = local.tags
}

####################
# IAM groups: human
####################
module "iam_group_administrator" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4.1"

  name = "Administrators"

  attach_iam_self_management_policy = false

  custom_group_policy_arns = [
    data.aws_iam_policy.administrator_access.arn
  ]

  group_users = [
    module.iam_user_acmers["user15@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user01@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user05@acme-corp.example"].iam_user_name,
    module.iam_user_system["acme-terraform"].iam_user_name,
    module.iam_user_acmers["user11@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user13@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user14@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user18@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user19@acme-corp.example"].iam_user_name,
  ]

  tags = local.tags
}

module "iam_group_acmers" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4.1"

  name = "Acmers"

  attach_iam_self_management_policy = true

  group_users = local.users.acmers

  tags = local.tags
}

module "iam_group_developers" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4.1"

  name = "Developers"

  attach_iam_self_management_policy = false

  custom_group_policy_arns = [
    data.aws_iam_policy.system_administrator_access.arn,
    data.aws_iam_policy.poweruser_access.arn,
  ]

  group_users = [
    module.iam_user_acmers["user04@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user05@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user25@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user12@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user10@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user20@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user21@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user22@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user06@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user07@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user08@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user09@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user13@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user14@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user16@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user17@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user18@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user23@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user24@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user26@acme-corp.example"].iam_user_name,
    module.iam_user_acmers["user27@acme-corp.example"].iam_user_name,
  ]

  tags = local.tags
}

#####################
# IAM groups: system
#####################
module "iam_group_system" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4.1"

  name = "System"

  attach_iam_self_management_policy = false

  group_users = local.users.system

  tags = local.tags
}

module "iam_group_deploy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 4.1"

  name = "Deploy"

  attach_iam_self_management_policy = false

  custom_group_policy_arns = [
    data.aws_iam_policy.amazon_s3_full_access.arn,
    data.aws_iam_policy.amazon_ecs_full_access.arn,
    aws_iam_policy.amazon_ecr_full_access.arn,
  ]

  group_users = [
    module.iam_user_system["deploy"].iam_user_name,
    module.iam_user_system["front-deploy"].iam_user_name,
  ]

  tags = local.tags
}

#####################################
# IAM user direct policy attachments
#####################################
resource "aws_iam_user_policy_attachment" "airflow_s3_access" {
  user       = module.iam_user_system["airflow"].iam_user_name
  policy_arn = aws_iam_policy.airflow_s3_access.arn
}

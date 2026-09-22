###################################################
# AWS managed IAM policies & service role policies
###################################################
// job functions
data "aws_iam_policy" "administrator_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "poweruser_access" {
  arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

data "aws_iam_policy" "system_administrator_access" {
  arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}

// S3
data "aws_iam_policy" "amazon_s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

data "aws_iam_policy" "amazon_s3_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_iam_policy" "amazon_s3_outposts_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3OutpostsFullAccess"
}

// ecs
data "aws_iam_policy" "amazon_ecs_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

data "aws_iam_policy" "amazon_ecs_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy"
}

data "aws_iam_policy" "amazon_ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "aws_application_autoscaling_ecs_service_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingECSServicePolicy"
}

// dynamodb
data "aws_iam_policy" "amazon_dynamodb_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "aws_iam_policy" "aws_application_autoscaling_dynamodb_table_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSApplicationAutoscalingDynamoDBTablePolicy"
}

// athena & glue
data "aws_iam_policy" "amazon_athena_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

data "aws_iam_policy" "aws_glue_service_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

data "aws_iam_policy" "aws_glue_console_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

// cloudwatch
data "aws_iam_policy" "cloudwatch_logs_read_only_access" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
}

// lakeformation
data "aws_iam_policy" "aws_lakeformation_cross_account_manager" {
  arn = "arn:aws:iam::aws:policy/AWSLakeFormationCrossAccountManager"
}

data "aws_iam_policy" "aws_lakeformation_data_admin" {
  arn = "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin"
}

// dms
data "aws_iam_policy" "amazon_dms_vpc_management_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

// rds
data "aws_iam_policy" "amazon_rds_enhanced_monitoring_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_policy" "amazon_rds_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AmazonRDSServiceRolePolicy"
}

// autoscaling
data "aws_iam_policy" "autoscaling_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AutoScalingServiceRolePolicy"
}

// cloudfront
data "aws_iam_policy" "aws_cloudfront_logger" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSCloudFrontLogger"
}

// codebuild & codedeploy
data "aws_iam_policy" "aws_codebuild_admin_access" {
  arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

data "aws_iam_policy" "aws_codebuild_developer_access" {
  arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

data "aws_iam_policy" "aws_codedeploy_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

data "aws_iam_policy" "aws_codedeploy_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

// elastic beanstalk
data "aws_iam_policy" "aws_elasticbeanstalk_enhanced_health" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

data "aws_iam_policy" "aws_elasticbeanstalk_managed_updates_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSElasticBeanstalkManagedUpdatesServiceRolePolicy"
}

data "aws_iam_policy" "aws_elasticbeanstalk_multicontainer_docker" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

data "aws_iam_policy" "aws_elasticbeanstalk_webtier" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy" "aws_elasticbeanstalk_workertier" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

// elb
data "aws_iam_policy" "aws_elb_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSElasticLoadBalancingServiceRolePolicy"
}

// global accelerator
data "aws_iam_policy" "aws_global_accelerator_slr_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSGlobalAcceleratorSLRPolicy"
}

// lambda
data "aws_iam_policy" "aws_lambda_basic_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "aws_lambda_eni_management_access" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

data "aws_iam_policy" "aws_lambda_replicator" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSLambdaReplicator"
}

// organizations
data "aws_iam_policy" "aws_organizations_service_trust_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSOrganizationsServiceTrustPolicy"
}

// support & trusted advisor
data "aws_iam_policy" "aws_support_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSSupportServiceRolePolicy"
}

data "aws_iam_policy" "aws_trusted_advisor_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSTrustedAdvisorServiceRolePolicy"
}

// elasticache
data "aws_iam_policy" "elasticache_service_role_policy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/ElastiCacheServiceRolePolicy"
}

// secrets manager
data "aws_iam_policy" "secrets_manager_readwrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

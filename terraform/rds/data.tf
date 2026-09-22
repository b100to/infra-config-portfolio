data "aws_caller_identity" "current" {}

data "aws_kms_key" "rds" {
  key_id = "alias/aws/rds"
}
provider "aws" {
  region = var.region[var.env]
}

terraform {

  # backend configuration

  backend "s3" {
    bucket = "name-bucket-tfstate" # name of bucket is unique in whole world, please, keep this in mind.
    key    = "dev/terraform.tfstate" # the key definition changes following the environment 
    region = "us-east-1" # select region according to your region defined in provider aws
  }
}

/*
The environment variable is sent to the module in order to select 
the correct configuration according to the environment. 
*/

/* As explained in the README, for the sake of strategy and control, 
we have separated the processes into Glue A and Glue B.
*/

# Below the module configuration.

module "resource_s3_bucket" {
  source = "../modules/buckets-s3"
  env    = var.env 
}

module "resource_glue_a" {
  source                 = "../modules/glue-a"
  env                    = var.env
  kms_key                = module.resource_s3_bucket.kms_key
  jdbc_user              = module.resource_aws_secret_manager.jdbc_user
  jdbc_pass              = module.resource_aws_secret_manager.jdbc_pass
  glue_role              = module.resource_iam_policies.glue_role
  glue_role_id           = module.resource_iam_policies.glue_role_id
  glue_security_group    = module.resource_iam_policies.security_group
  glue_security_group_id = module.resource_iam_policies.security_group_id
}

module "resource_glue_b" {
  source                 = "../modules/glue-b"
  env                    = var.env
  kms_key                = module.resource_s3_bucket.kms_key
  glue_role              = module.resource_iam_policies.glue_role
  glue_role_id           = module.resource_iam_policies.glue_role_id
  glue_role_redshift     = module.resource_iam_policies.glue_role_redshift
  glue_security_group    = module.resource_iam_policies.security_group
  glue_security_group_id = module.resource_iam_policies.security_group_id
  redshift_user          = module.resource_aws_secret_manager.redshift_user
  redshift_pass          = module.resource_aws_secret_manager.redshift_pass
}

module "resource_redshift" {
  source        = "../modules/redshift"
  env           = var.env
  redshift_role = module.resource_iam_policies.redshift_role
  redshift_user = module.resource_aws_secret_manager.redshift_user
  redshift_pass = module.resource_aws_secret_manager.redshift_pass
}

module "resource_transfer_family" {
  source          = "../modules/transfer-family"
  env             = var.env
  role_transfer   = module.resource_iam_policies.transfer_role
  bucket_transfer = module.resource_s3_bucket.bucket_id
  ssh_key         = module.resource_aws_secret_manager.transfer_ssh_key
}

module "resource_sagemaker" {
  source   = "../modules/sagemaker"
  env      = var.env
  role_arn = module.resource_iam_policies.sagemaker_role
}

module "resource_athena_database" {
  source      = "../modules/athena"
  env         = var.env
  bucket_logs = module.resource_s3_bucket.bucket_log
}

module "resource_iam_policies" {
  source = "../modules/policies"
  env    = var.env
}

module "resource_aws_network" {
  source = "../modules/network"
  env    = var.env
}

module "resource_aws_lambda" {
  source                     = "../modules/lambdas"
  env                        = var.env
  role_arn                   = module.resource_iam_policies.lambda_redshift_role
  iam_role                   = module.resource_iam_policies.redshift_role
  redshift_user              = module.resource_aws_secret_manager.redshift_user
  redshift_pass              = module.resource_aws_secret_manager.redshift_pass
  role_arn_step_functions    = module.resource_iam_policies.lambda_stepfunctions_role
  state_machine_discador_arn = module.resource_aws_step_functions.state_machine_arn
  bucket_transfer            = module.resource_s3_bucket.bucket_id
  bucket_arn                 = module.resource_s3_bucket.bucket_arn
}

module "resource_aws_secret_manager" {
  source = "../modules/secret-manager"
  env    = var.env
}

module "resource_aws_step_functions" {
  source                  = "../modules/step-functions"
  env                     = var.env
  lambda_function         = module.resource_aws_lambda.lambda_arn
  role_arn_step_functions = module.resource_iam_policies.stepfunctions_lambda_role
}

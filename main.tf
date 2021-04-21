#############################################################
# Locals
#############################################################

locals {
  authentication_token_ssm_param                  = var.authentication_token_ssm_param != null ? var.authentication_token_ssm_param : "/${module.auth_token_ssm_param_label.id}"
  authentication_token_ssm_param_kms_key_provided = var.authentication_token_ssm_param_kms_key != null ? true : false
}

#############################################################
# Labels
#############################################################

module "default_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = var.attributes
  delimiter  = var.delimiter
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags
}

module "auth_token_ssm_param_label" {
  enabled = var.authentication_token_ssm_param != null ? false : true

  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.default_label.context
  attributes = compact(concat(var.attributes, ["auth_token"]))
  delimiter  = "/"
}

#############################################################
# Data sources
#############################################################

data "aws_region" "default" {
}

data "aws_availability_zone" "default" {
  name  = "${data.aws_region.default.name}${var.availability_zone}"
  state = "available"
}

data "aws_partition" "default" {}

data "aws_caller_identity" "default" {}

#############################################################
# SSM Param for storing runner's auth token
#############################################################

# The following is mostly required to be 100% sure that runner will be
# unregistered from Gitlab

data "aws_kms_key" "authentication_token" {
  count = local.authentication_token_ssm_param_kms_key_provided ? 1 : 0

  key_id = var.authentication_token_ssm_param_kms_key
}

resource "aws_ssm_parameter" "authentication_token" {
  name  = local.authentication_token_ssm_param
  type  = "SecureString"
  value = "empty"

  tags = module.default_label.tags

  key_id = join("", data.aws_kms_key.authentication_token.*.arn)

  lifecycle {
    ignore_changes = [value]
  }
}

#############################################################
# Service-Linked Roles
#############################################################

resource "aws_iam_service_linked_role" "spot" {
  count = var.create_spot_service_linked_role ? 1 : 0

  aws_service_name = "spot.amazonaws.com"
}

resource "aws_iam_service_linked_role" "autoscaling" {
  count = var.create_autoscaling_service_linked_role ? 1 : 0

  aws_service_name = "autoscaling.amazonaws.com"
}

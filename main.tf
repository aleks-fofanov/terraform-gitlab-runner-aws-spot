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
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  attributes = var.attributes
  delimiter  = var.delimiter
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags
}

module "auth_token_ssm_param_label" {
  enabled = var.authentication_token_ssm_param != null ? false : true

  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.17.0"
  attributes = compact(concat(var.attributes, ["auth_token"]))
  delimiter  = "/"
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags
}

#############################################################
# Data sources
#############################################################

data "aws_region" "default" {
  name = var.region
}

data "aws_availability_zone" "default" {
  name  = "${var.region}${var.availability_zone}"
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

resource "null_resource" "unregister_runner" {
  triggers = {
    script             = "${path.module}/scripts/unregister-runner.sh"
    aws_region         = var.region
    runners_gitlab_url = var.gitlab_url
    ssm_param_name     = aws_ssm_parameter.authentication_token.name
    instance_id        = module.manager_instance.id
  }

  provisioner "local-exec" {
    when        = destroy
    on_failure  = continue
    interpreter = ["/bin/bash", "-c"]
    command     = "${self.triggers.script} -p ${self.triggers.ssm_param_name} -r ${self.triggers.aws_region} -u ${self.triggers.runners_gitlab_url}"
  }
}

#############################################################
# Service-linked Roles
#############################################################

resource "aws_iam_service_linked_role" "spot" {
  count = var.create_service_linked_roles ? 1 : 0

  aws_service_name = "spot.amazonaws.com"
}

resource "aws_iam_service_linked_role" "autoscaling" {
  count = var.create_service_linked_roles ? 1 : 0

  aws_service_name = "autoscaling.amazonaws.com"
}

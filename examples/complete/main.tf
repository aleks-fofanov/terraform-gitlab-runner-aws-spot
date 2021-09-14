#############################################################
# Providers
#############################################################

provider "aws" {
  region = var.aws_region
}

#############################################################
# Data sources to get region, availability zones etc.
#############################################################

data "aws_region" "current" {}

data "aws_availability_zones" "aws_availability_zones" {
  state = "available"
}

#############################################################
# Runner
#############################################################

module "runner" {
  source  = "aleks-fofanov/runner-aws-spot/gitlab"
  version = "~> 2.0"

  attributes = var.attributes
  delimiter  = var.delimiter
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags

  gitlab_runner_version = "13.10.0"

  availability_zone = var.aws_az

  registration_token_ssm_param         = "/tf/${var.name}/${var.stage}/registration_token"
  registration_token_ssm_param_kms_key = "alias/aws/ssm"

  authentication_token_ssm_param         = "/tf/${var.name}/${var.stage}/authentication_token"
  authentication_token_ssm_param_kms_key = "alias/aws/ssm"

  create_spot_service_linked_role        = true
  create_autoscaling_service_linked_role = true
  enable_ssm_sessions                    = true
  enable_s3_cache                        = true

  vpc = {
    vpc_id     = module.vpc.vpc_id
    cidr_block = module.vpc.vpc_cidr_block
  }

  manager = {
    ami_id                               = "ami-0518bb0e75d3619ca"
    ami_owner                            = "amazon"
    instance_type                        = "t3a.micro"
    key_pair                             = null
    subnet_id                            = lookup(module.subnets.az_subnet_ids, join("", [data.aws_region.current.name, var.aws_az]))
    associate_public_ip_address          = true
    assign_eip_address                   = false
    enable_detailed_monitoring           = false
    root_volume_size                     = 8
    ebs_optimized                        = false
    metadata_http_endpoint_enabled       = true
    metadata_http_put_response_hop_limit = 2
    metadata_http_tokens_required        = true
  }

  runner = {
    concurrent = 2
    limit      = 2
    tags       = ["shared", "docker", "spot", join("", [data.aws_region.current.name, var.aws_az])]
    image      = "docker:20.10"

    instance_type       = "c5.large"
    ami_id              = "ami-007e276c37b5ff2d7"
    use_private_address = true

    spot_bid_price         = 0.11
    spot_block_duration    = 0
    request_spot_instances = true

    run_untagged    = false
    lock_to_project = true

    idle = {
      count = 0
      time  = 1200
    }

    autoscaling_periods = [
      {
        periods    = ["* * 9-17 * * mon-fri *"]
        idle_count = 1
        idle_time  = 1200
        timezone   = "UTC"
      }
    ]
  }
}

#############################################################
# Locals
#############################################################

# Links:
# https://gitlab.com/gitlab-org/gitlab-runner/issues/4735

locals {
  default_docker_volumes = ["/cache"]
  all_docker_volumes     = compact(concat(local.default_docker_volumes, var.runner_advanced_config.additional_volumes))
  docker_volumes_clauses = join(" ",
    [for volume in local.all_docker_volumes : "--docker-volumes '${volume}'"]
  )

  gitlab_runner_config_path   = "/etc/gitlab-runner/config.toml"
  runner_template_config_path = "/etc/gitlab-runner/runner.template.toml"
}

#############################################################
# Templates
#############################################################

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.sh")

  vars = {
    gitlab_runner_version  = var.gitlab_runner_version
    docker_machine_version = var.docker_machine_version

    gitlab_runner_config_path    = local.gitlab_runner_config_path
    gitlab_runner_config_content = data.template_file.gitlab_runner_config.rendered
    template_config_path         = local.runner_template_config_path
    template_config_content      = data.template_file.gitlab_runner_config_template.rendered
    svc_script                   = data.template_file.manager_svc.rendered

    logs_configuration = join("", data.template_file.manager_logs.*.rendered)
    ecr_configuration  = join("", data.template_file.manager_ecr.*.rendered)
  }
}

data "template_file" "manager_logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  template = file("${path.module}/templates/awslogs.sh")

  vars = {
    include_ssm_logs          = var.enable_ssm_sessions
    cloudwatch_log_group_name = join("", aws_cloudwatch_log_group.manager.*.name)
  }
}

data "template_file" "manager_ecr" {
  count = length(var.enable_access_to_ecr_repositories) > 0 ? 1 : 0

  template = file("${path.module}/templates/ecr.sh")

  vars = {
    account_id = data.aws_caller_identity.default.account_id
    region     = data.aws_region.default.name
  }
}

# Links:
# https://docs.gitlab.com/runner/configuration/advanced-configuration.html
# https://github.com/Nordstrom/docker-machine/blob/master/docs/drivers/aws.md

data "template_file" "gitlab_runner_config" {
  template = file("${path.module}/templates/gitlab.runner.config.toml")

  vars = {
    concurent    = var.runner.concurent
    metrics_port = var.metrics_port
  }
}

data "template_file" "gitlab_runner_config_template" {
  template = file("${path.module}/templates/gitlab.runner.config.template.toml")

  vars = {
    manager_name = module.manager_label.id
    gitlab_url   = var.gitlab_url
    limit        = var.runner.limit

    runner_name         = module.runner_label.id
    aws_region          = data.aws_region.default.name
    aws_az              = var.availability_zone
    vpc_id              = var.vpc.vpc_id
    subnet_id           = var.manager.subnet_id
    security_group      = aws_security_group.runners.name
    use_private_address = var.runner.use_private_address
    instance_profile    = aws_iam_instance_profile.runner.name
    instance_type       = var.runner.instance_type
    ami_id              = var.runner.ami_id
    tags                = join(",", var.runner.tags)
    image               = var.runner.image

    spot_price          = var.runner.spot_bid_price
    spot_block_duration = var.runner.spot_block_duration
    idle_count          = var.runner.idle.count
    idle_time           = var.runner.idle.time

    off_peak_idle_count = var.runner.off_peak.idle_count
    off_peak_idle_time  = var.runner.off_peak.idle_time
    off_peak_timezone   = var.runner.off_peak.timezone
    off_peak_periods    = jsonencode(var.runner.off_peak.periods)

    pre_build_script           = var.runner_advanced_config.pre_build_script
    post_build_script          = var.runner_advanced_config.post_build_script
    pre_clone_script           = var.runner_advanced_config.pre_clone_script
    environment                = jsonencode(var.runner_advanced_config.environment)
    request_concurrency        = var.runner_advanced_config.request_concurrency
    output_limit               = var.runner_advanced_config.output_limit
    shm_size                   = var.runner_advanced_config.shm_size
    max_builds                 = var.runner_advanced_config.max_builds
    pull_policy                = var.runner_advanced_config.pull_policy
    additional_volumes         = join(", ", [for volume in local.all_docker_volumes : "\"${volume}\""])
    other_machine_options      = join(", ", [for option in var.runner_advanced_config.additional_docker_machine_options : "\"${option}\""])
    root_volume_size           = var.runner_advanced_config.root_volume_size
    ebs_optimized              = var.runner_advanced_config.ebs_optimized
    enable_detailed_monitoring = var.runner_advanced_config.enable_detailed_monitoring

    s3_cache_enabled = var.enable_s3_cache
    bucket_name      = module.s3_cache_bucket.bucket_id
  }
}

data "template_file" "manager_svc" {
  template = file("${path.module}/templates/gitlab-runner-svc.sh")

  vars = {
    gitlab_runner_config_path = local.gitlab_runner_config_path
    template_config_path      = local.runner_template_config_path

    gitlab_url                   = var.gitlab_url
    registration_token           = local.registration_token_in_ssm_param ? "" : var.registration_token
    registration_token_ssm_param = local.registration_token_in_ssm_param ? var.registration_token_ssm_param : ""
    auth_token_ssm_param_name    = aws_ssm_parameter.authentication_token.name
    auth_token_ssm_param_kms_key = join("", data.aws_kms_key.authentication_token.*.arn)
    region                       = data.aws_region.default.name
    docker_volumes_clauses       = local.docker_volumes_clauses

    runner_name  = module.runner_label.id
    tags         = join(",", var.runner.tags)
    image        = var.runner.image
    locked       = var.runner.lock_to_project
    run_untagged = var.runner.run_untagged
  }
}

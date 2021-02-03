#############################################################
# Locals
#############################################################

locals {
  # Links:
  # https://gitlab.com/gitlab-org/gitlab-runner/issues/4735

  default_docker_volumes = ["/cache"]
  all_docker_volumes = compact(concat(
    local.default_docker_volumes,
    var.runner_advanced_config.additional_volumes
  ))
  docker_volumes_clauses = join(" ",
    [for volume in local.all_docker_volumes : "--docker-volumes '${volume}'"]
  )

  gitlab_runner_config_path   = "/etc/gitlab-runner/config.toml"
  runner_template_config_path = "/etc/gitlab-runner/runner.template.toml"

  # ----------------------------------------------------------------------------
  # Gitlab runner config template
  # ----------------------------------------------------------------------------

  # Links:
  # https://docs.gitlab.com/runner/configuration/advanced-configuration.html
  # https://github.com/Nordstrom/docker-machine/blob/master/docs/drivers/aws.md

  gitlab_runner_config_template_vars = {
    concurrent   = var.runner.concurrent
    metrics_port = var.metrics_port
  }
  gitlab_runner_config_template_rendered = templatefile(
    "${path.module}/templates/gitlab.runner.config.toml",
    local.gitlab_runner_config_template_vars
  )

  # ----------------------------------------------------------------------------
  # Docker machine runner template
  # ----------------------------------------------------------------------------

  runner_template_vars = {
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

    idle_count = var.runner.idle.count
    idle_time  = var.runner.idle.time

    autoscaling_periods = var.runner.autoscaling_periods

    request_spot_instances = var.runner.request_spot_instances
    spot_price             = var.runner.spot_bid_price
    spot_block_duration    = var.runner.spot_block_duration

    pre_build_script           = var.runner_advanced_config.pre_build_script
    post_build_script          = var.runner_advanced_config.post_build_script
    pre_clone_script           = var.runner_advanced_config.pre_clone_script
    environment                = jsonencode(var.runner_advanced_config.environment)
    request_concurrency        = var.runner_advanced_config.request_concurrency
    output_limit               = var.runner_advanced_config.output_limit
    shm_size                   = var.runner_advanced_config.shm_size
    max_builds                 = var.runner_advanced_config.max_builds
    pull_policy                = var.runner_advanced_config.pull_policy
    additional_volumes         = local.all_docker_volumes
    other_machine_options      = var.runner_advanced_config.additional_docker_machine_options
    root_volume_size           = var.runner_advanced_config.root_volume_size
    ebs_optimized              = var.runner_advanced_config.ebs_optimized
    enable_detailed_monitoring = var.runner_advanced_config.enable_detailed_monitoring

    s3_cache_enabled   = var.enable_s3_cache
    bucket_name        = module.s3_cache_bucket.bucket_id
    gcr_mirror_enabled = var.enable_gcr_mirror_for_dockerhub
  }
  runner_template_rendered = templatefile(
    "${path.module}/templates/gitlab.runner.config.template.toml",
    local.runner_template_vars
  )

  # ----------------------------------------------------------------------------
  # Manager's service config template
  # ----------------------------------------------------------------------------

  manager_svc_template_vars = {
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
  manager_svc_template_rendered = templatefile(
    "${path.module}/templates/gitlab-runner-svc.sh",
    local.manager_svc_template_vars
  )

  # ----------------------------------------------------------------------------
  # Manager's log config template
  # ----------------------------------------------------------------------------

  manager_logs_template_vars = {
    include_ssm_logs          = var.enable_ssm_sessions
    cloudwatch_log_group_name = join("", aws_cloudwatch_log_group.manager.*.name)
  }
  manager_logs_template_rendered = templatefile(
    "${path.module}/templates/awslogs.sh",
    local.manager_logs_template_vars
  )

  # ----------------------------------------------------------------------------
  # Manager's ECR credentials helper config template
  # ----------------------------------------------------------------------------

  manager_ecr_template_vars = {
    account_id = data.aws_caller_identity.default.account_id
    region     = data.aws_region.default.name
  }
  manager_ecr_template_rendered = templatefile(
    "${path.module}/templates/ecr.sh",
    local.manager_ecr_template_vars
  )

  # ----------------------------------------------------------------------------
  # Manager's Registry Proxy for Docker Hub
  # ----------------------------------------------------------------------------

  manager_registry_proxy_template_rendered = templatefile(
    "${path.module}/templates/registry-proxy.sh",
    {}
  )

  # ----------------------------------------------------------------------------
  # Manager's user data
  # ----------------------------------------------------------------------------

  manager_user_data_template_vars = {
    gitlab_runner_version  = var.gitlab_runner_version
    docker_machine_version = var.docker_machine_version

    gitlab_runner_config_path    = local.gitlab_runner_config_path
    gitlab_runner_config_content = local.gitlab_runner_config_template_rendered
    template_config_path         = local.runner_template_config_path
    template_config_content      = local.runner_template_rendered
    svc_script                   = local.manager_svc_template_rendered

    logs_configuration            = var.enable_cloudwatch_logs ? local.manager_logs_template_rendered : ""
    ecr_configuration             = length(var.enable_access_to_ecr_repositories) > 0 ? local.manager_ecr_template_rendered : ""
    registry_mirror_configuration = var.enable_gcr_mirror_for_dockerhub ? local.manager_registry_proxy_template_rendered : ""
  }
  manager_user_data_template_rendered = templatefile("${path.module}/templates/user-data.sh", local.manager_user_data_template_vars)
}

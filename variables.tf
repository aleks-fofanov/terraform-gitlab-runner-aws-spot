variable "namespace" {
  type        = string
  description = "Namespace (e.g. `cp` or `cloudposse`)"
  default     = ""
}

variable "stage" {
  type        = string
  description = "Stage (e.g. `prod`, `dev`, `staging`)"
  default     = ""
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `name`, `stage` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes, e.g. `1`"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map(`BusinessUnit`,`XYZ`)"
}

variable "region" {
  description = "AWS Region identifier for instances to be launched in"
}

variable "availability_zone" {
  type        = string
  description = "Availability Zone (e.g. `a`, `b`, `c` etc.) for instances to be launched in"
  default     = "a"
}

variable "gitlab_url" {
  type        = string
  default     = "https://gitlab.com"
  description = "Gitlab URL"
}

variable "registration_token" {
  type        = string
  default     = null
  description = "Runner registration token"
}

variable "registration_token_ssm_param" {
  type        = string
  default     = null
  description = "SSM Parameter name that stored runner registration token. This parameter takes precedence over `registration_token`"
}

variable "registration_token_ssm_param_kms_key" {
  type        = string
  default     = null
  description = "Identifier of KMS key used for encryption of SSM Parameter that stores registration token"
}

variable "authentication_token_ssm_param" {
  type        = string
  default     = null
  description = "An override for SSM Parameter name that will store runner authentication token"
}

variable "authentication_token_ssm_param_kms_key" {
  type        = string
  default     = null
  description = "Identifier of KMS key used for encryption of SSM Parameter that will store authentication token"
}

variable "vpc" {
  type = object({
    vpc_id     = string
    cidr_block = string
  })
  description = "VPC configuration"
}

variable "manager" {
  description = "Runners' manager (aka bastion) configuration"
  type = object({
    ami_id                      = string
    ami_owner                   = string
    instance_type               = string
    key_pair                    = string
    subnet_id                   = string
    associate_public_ip_address = bool
    assign_eip_address          = bool
    root_volume_size            = number
    ebs_optimized               = bool
    enable_detailed_monitoring  = bool
  })
}

variable "runner" {
  description = "Gitlab runner configuration. See https://docs.gitlab.com/runner/configuration/advanced-configuration.html"
  type = object({
    concurent = number
    limit     = number

    image = string
    tags  = list(string)

    use_private_address = bool
    instance_type       = string
    ami_id              = string

    spot_bid_price      = number
    spot_block_duration = number
    run_untagged        = bool
    lock_to_project     = bool

    idle = object({
      count = number
      time  = number
    })
    off_peak = object({
      timezone   = string
      idle_count = number
      idle_time  = number
      periods    = list(string)
    })
  })
}

# Links:
# https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#tls-enabled

variable "runner_advanced_config" {
  type = object({
    pre_build_script                  = string
    post_build_script                 = string
    pre_clone_script                  = string
    environment                       = list(string)
    request_concurrency               = number
    output_limit                      = number
    shm_size                          = number
    max_builds                        = number
    pull_policy                       = string
    additional_volumes                = list(string)
    additional_docker_machine_options = list(string)
    root_volume_size                  = number
    ebs_optimized                     = bool
    enable_detailed_monitoring        = bool
  })
  default = {
    pre_build_script                  = ""
    post_build_script                 = ""
    pre_clone_script                  = ""
    environment                       = []
    request_concurrency               = 1
    output_limit                      = 4096
    shm_size                          = 0
    max_builds                        = 0
    pull_policy                       = "always"
    additional_volumes                = ["/certs/client"]
    additional_docker_machine_options = []
    root_volume_size                  = 20
    ebs_optimized                     = false
    enable_detailed_monitoring        = false
  }
  description = "Advanced configuration options for gitlab runner"
}

variable "docker_machine_version" {
  default     = "0.16.2-gitlab.2"
  type        = string
  description = "Docker machine version to be installed on manager instance"
}

variable "gitlab_runner_version" {
  default     = "12.10.0"
  type        = string
  description = "Gitlab runner version to be installed on manager instance"
}

variable "create_service_linked_roles" {
  default     = true
  type        = bool
  description = "Defines whether required service-linked roles should be created"
}

variable "enable_cloudwatch_logs" {
  default     = true
  type        = bool
  description = "Defines whether manager instance should ship its logs to Cloudwatch"
}

variable "cloudwatch_logs_retention" {
  default     = 30
  type        = number
  description = "Number of days you want to retain log events in Cloudwatch log group"
}

variable "cloudwatch_logs_kms_key_arn" {
  type        = string
  default     = null
  description = "The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested."
}

variable "enable_s3_cache" {
  default     = true
  type        = bool
  description = "Defines whether s3 should be created and used as a source for distributed cache"
}

variable "s3_cache_infrequent_access_transition" {
  type        = number
  default     = 30
  description = "Number of days to persist in the standard storage tier before moving to the infrequent access tier"
}

variable "s3_cache_expiration" {
  type        = number
  default     = 45
  description = "Number of days you want to retain cache in S3 bucket"
}

variable "enable_ssm_sessions" {
  default     = true
  type        = bool
  description = "Defines whether access via SSM Session Manager should be enabled for manager instance"
}

variable "enable_access_to_ecr_repositories" {
  type        = list(string)
  default     = []
  description = "A list of ECR repositories in specified `region` that manager instance should have read-only access to"
}

variable "metrics_port" {
  type        = number
  default     = 9252
  description = "See https://docs.gitlab.com/runner/monitoring/#configuration-of-the-metrics-http-server for more details"
}

variable "additional_security_groups" {
  description = "List of Security Group IDs allowed to be associated with manager instance"
  type        = list(string)
  default     = []
}

variable "allowed_metrics_cidr_blocks" {
  type = list(object({
    cidr_blocks = list(string)
    description = string
  }))
  default     = []
  description = "CIDR blocks that should be able to access metrics port exposed on manager instance"
}

variable "allowed_ssh_cidr_blocks" {
  type = list(object({
    cidr_blocks = list(string)
    description = string
  }))
  default     = []
  description = "CIDR blocks that should be able to communicate with manager's 22 port"
}

variable "shell" {
  default     = "/bin/bash"
  description = ""
}

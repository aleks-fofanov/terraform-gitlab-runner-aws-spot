## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aggregated_policy"></a> [aggregated\_policy](#module\_aggregated\_policy) | cloudposse/iam-policy-document-aggregator/aws | 0.8.0 |
| <a name="module_auth_token_ssm_param_label"></a> [auth\_token\_ssm\_param\_label](#module\_auth\_token\_ssm\_param\_label) | git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.24.1 |  |
| <a name="module_default_label"></a> [default\_label](#module\_default\_label) | git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.24.1 |  |
| <a name="module_manager_instance"></a> [manager\_instance](#module\_manager\_instance) | cloudposse/ec2-instance/aws | 0.30.4 |
| <a name="module_manager_label"></a> [manager\_label](#module\_manager\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_runner_label"></a> [runner\_label](#module\_runner\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_s3_cache_bucket"></a> [s3\_cache\_bucket](#module\_s3\_cache\_bucket) | cloudposse/s3-bucket/aws | 0.33.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_instance_profile.runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.manager_cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.manager_ssm_sessions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_service_linked_role.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_iam_service_linked_role.spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_s3_bucket_public_access_block.cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.runners](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.manacache_s3_bucketger_ssh_from_allowed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.manager_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.manager_metrics_from_allowed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.runners_docker_machine_from_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.runners_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.runners_icmp_from_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.runners_ssh_from_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.authentication_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [null_resource.unregister_runner](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_availability_zone.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zone) | data source |
| [aws_caller_identity.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.authentication_token_kms_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.authentication_token_ssm_param_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.create_service_linked_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.docker_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.registration_token_kms_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.registration_token_ssm_param_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.runner_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_sessions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.authentication_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_kms_key.registration_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_partition.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.registration_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_manager"></a> [manager](#input\_manager) | Runners' manager (aka bastion) configuration | <pre>object({<br>    ami_id                      = string<br>    ami_owner                   = string<br>    instance_type               = string<br>    key_pair                    = string<br>    subnet_id                   = string<br>    associate_public_ip_address = bool<br>    assign_eip_address          = bool<br>    root_volume_size            = number<br>    ebs_optimized               = bool<br>    enable_detailed_monitoring  = bool<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region identifier for instances to be launched in | `any` | n/a | yes |
| <a name="input_runner"></a> [runner](#input\_runner) | Gitlab runner configuration. See https://docs.gitlab.com/runner/configuration/advanced-configuration.html | <pre>object({<br>    concurrent = number<br>    limit      = number<br><br>    image = string<br>    tags  = list(string)<br><br>    use_private_address = bool<br>    instance_type       = string<br>    ami_id              = string<br><br>    run_untagged    = bool<br>    lock_to_project = bool<br><br>    idle = object({<br>      count = number<br>      time  = number<br>    })<br><br>    autoscaling_periods = list(object({<br>      periods    = list(string)<br>      idle_count = number<br>      idle_time  = number<br>      timezone   = string<br>    }))<br><br>    request_spot_instances = bool<br>    spot_bid_price         = number<br>    spot_block_duration    = number<br>  })</pre> | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | VPC configuration | <pre>object({<br>    vpc_id     = string<br>    cidr_block = string<br>  })</pre> | n/a | yes |
| <a name="input_additional_security_groups"></a> [additional\_security\_groups](#input\_additional\_security\_groups) | List of Security Group IDs allowed to be associated with manager instance | `list(string)` | `[]` | no |
| <a name="input_allowed_metrics_cidr_blocks"></a> [allowed\_metrics\_cidr\_blocks](#input\_allowed\_metrics\_cidr\_blocks) | CIDR blocks that should be able to access metrics port exposed on manager instance | <pre>list(object({<br>    cidr_blocks = list(string)<br>    description = string<br>  }))</pre> | `[]` | no |
| <a name="input_allowed_ssh_cidr_blocks"></a> [allowed\_ssh\_cidr\_blocks](#input\_allowed\_ssh\_cidr\_blocks) | CIDR blocks that should be able to communicate with manager's 22 port | <pre>list(object({<br>    cidr_blocks = list(string)<br>    description = string<br>  }))</pre> | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes, e.g. `1` | `list(string)` | `[]` | no |
| <a name="input_authentication_token_ssm_param"></a> [authentication\_token\_ssm\_param](#input\_authentication\_token\_ssm\_param) | An override for SSM Parameter name that will store runner authentication token | `string` | `null` | no |
| <a name="input_authentication_token_ssm_param_kms_key"></a> [authentication\_token\_ssm\_param\_kms\_key](#input\_authentication\_token\_ssm\_param\_kms\_key) | Identifier of KMS key used for encryption of SSM Parameter that will store authentication token | `string` | `null` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability Zone (e.g. `a`, `b`, `c` etc.) for instances to be launched in | `string` | `"a"` | no |
| <a name="input_cloudwatch_logs_kms_key_arn"></a> [cloudwatch\_logs\_kms\_key\_arn](#input\_cloudwatch\_logs\_kms\_key\_arn) | The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested. | `string` | `null` | no |
| <a name="input_cloudwatch_logs_retention"></a> [cloudwatch\_logs\_retention](#input\_cloudwatch\_logs\_retention) | Number of days you want to retain log events in Cloudwatch log group | `number` | `30` | no |
| <a name="input_create_service_linked_roles"></a> [create\_service\_linked\_roles](#input\_create\_service\_linked\_roles) | Defines whether required service-linked roles should be created | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `name`, `stage` and `attributes` | `string` | `"-"` | no |
| <a name="input_docker_machine_version"></a> [docker\_machine\_version](#input\_docker\_machine\_version) | Docker machine version to be installed on manager instance | `string` | `"0.16.2-gitlab.11"` | no |
| <a name="input_enable_access_to_ecr_repositories"></a> [enable\_access\_to\_ecr\_repositories](#input\_enable\_access\_to\_ecr\_repositories) | A list of ECR repositories in specified `region` that manager instance should have read-only access to | `list(string)` | `[]` | no |
| <a name="input_enable_cloudwatch_logs"></a> [enable\_cloudwatch\_logs](#input\_enable\_cloudwatch\_logs) | Defines whether manager instance should ship its logs to Cloudwatch | `bool` | `true` | no |
| <a name="input_enable_s3_cache"></a> [enable\_s3\_cache](#input\_enable\_s3\_cache) | Defines whether s3 should be created and used as a source for distributed cache | `bool` | `true` | no |
| <a name="input_enable_ssm_sessions"></a> [enable\_ssm\_sessions](#input\_enable\_ssm\_sessions) | Defines whether access via SSM Session Manager should be enabled for manager instance | `bool` | `true` | no |
| <a name="input_gitlab_runner_version"></a> [gitlab\_runner\_version](#input\_gitlab\_runner\_version) | Gitlab runner version to be installed on manager instance | `string` | `"13.10.0"` | no |
| <a name="input_gitlab_url"></a> [gitlab\_url](#input\_gitlab\_url) | Gitlab URL | `string` | `"https://gitlab.com"` | no |
| <a name="input_metrics_port"></a> [metrics\_port](#input\_metrics\_port) | See https://docs.gitlab.com/runner/monitoring/#configuration-of-the-metrics-http-server for more details | `number` | `9252` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (e.g. `cp` or `cloudposse`) | `string` | `""` | no |
| <a name="input_registration_token"></a> [registration\_token](#input\_registration\_token) | Runner registration token | `string` | `null` | no |
| <a name="input_registration_token_ssm_param"></a> [registration\_token\_ssm\_param](#input\_registration\_token\_ssm\_param) | SSM Parameter name that stored runner registration token. This parameter takes precedence over `registration_token` | `string` | `null` | no |
| <a name="input_registration_token_ssm_param_kms_key"></a> [registration\_token\_ssm\_param\_kms\_key](#input\_registration\_token\_ssm\_param\_kms\_key) | Identifier of KMS key used for encryption of SSM Parameter that stores registration token | `string` | `null` | no |
| <a name="input_runner_advanced_config"></a> [runner\_advanced\_config](#input\_runner\_advanced\_config) | Advanced configuration options for gitlab runner | <pre>object({<br>    pre_build_script                  = string<br>    post_build_script                 = string<br>    pre_clone_script                  = string<br>    environment                       = list(string)<br>    request_concurrency               = number<br>    output_limit                      = number<br>    shm_size                          = number<br>    max_builds                        = number<br>    pull_policy                       = string<br>    additional_volumes                = list(string)<br>    additional_docker_machine_options = list(string)<br>    root_volume_size                  = number<br>    ebs_optimized                     = bool<br>    enable_detailed_monitoring        = bool<br>  })</pre> | <pre>{<br>  "additional_docker_machine_options": [],<br>  "additional_volumes": [<br>    "/certs/client"<br>  ],<br>  "ebs_optimized": false,<br>  "enable_detailed_monitoring": false,<br>  "environment": [],<br>  "max_builds": 0,<br>  "output_limit": 4096,<br>  "post_build_script": "",<br>  "pre_build_script": "",<br>  "pre_clone_script": "",<br>  "pull_policy": "always",<br>  "request_concurrency": 1,<br>  "root_volume_size": 20,<br>  "shm_size": 0<br>}</pre> | no |
| <a name="input_s3_cache_expiration"></a> [s3\_cache\_expiration](#input\_s3\_cache\_expiration) | Number of days you want to retain cache in S3 bucket | `number` | `45` | no |
| <a name="input_s3_cache_infrequent_access_transition"></a> [s3\_cache\_infrequent\_access\_transition](#input\_s3\_cache\_infrequent\_access\_transition) | Number of days to persist in the standard storage tier before moving to the infrequent access tier | `number` | `30` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage (e.g. `prod`, `dev`, `staging`) | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map(`BusinessUnit`,`XYZ`)` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth_token_ssm_param_arn"></a> [auth\_token\_ssm\_param\_arn](#output\_auth\_token\_ssm\_param\_arn) | ARN of SSM Parameter that stores runner's authentication token |
| <a name="output_auth_token_ssm_param_name"></a> [auth\_token\_ssm\_param\_name](#output\_auth\_token\_ssm\_param\_name) | Name of SSM Parameter that stores runner's authentication token |
| <a name="output_manager_instance"></a> [manager\_instance](#output\_manager\_instance) | Disambiguated ID of manager instance |
| <a name="output_manager_instance_cloudwatch_alarm"></a> [manager\_instance\_cloudwatch\_alarm](#output\_manager\_instance\_cloudwatch\_alarm) | CloudWatch Alarm ID created for manager instance |
| <a name="output_manager_instance_cloudwatch_log_group_arn"></a> [manager\_instance\_cloudwatch\_log\_group\_arn](#output\_manager\_instance\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch Log Group created for manager instance |
| <a name="output_manager_instance_cloudwatch_log_group_name"></a> [manager\_instance\_cloudwatch\_log\_group\_name](#output\_manager\_instance\_cloudwatch\_log\_group\_name) | Name of CloudWatch Log Group created for manager instance |
| <a name="output_manager_instance_name"></a> [manager\_instance\_name](#output\_manager\_instance\_name) | Manager instance name |
| <a name="output_manager_instance_policy_arn"></a> [manager\_instance\_policy\_arn](#output\_manager\_instance\_policy\_arn) | ARN of AWS IAM Policy associated with manager instance IAM role |
| <a name="output_manager_instance_policy_name"></a> [manager\_instance\_policy\_name](#output\_manager\_instance\_policy\_name) | Name of AWS IAM Policy associated with manager instance IAM role |
| <a name="output_manager_instance_primary_security_group_id"></a> [manager\_instance\_primary\_security\_group\_id](#output\_manager\_instance\_primary\_security\_group\_id) | An ID of security group created for and associated with manager instance |
| <a name="output_manager_instance_private_dns"></a> [manager\_instance\_private\_dns](#output\_manager\_instance\_private\_dns) | Private DNS of manager instance |
| <a name="output_manager_instance_private_ip"></a> [manager\_instance\_private\_ip](#output\_manager\_instance\_private\_ip) | Private IP of manager instance |
| <a name="output_manager_instance_public_dns"></a> [manager\_instance\_public\_dns](#output\_manager\_instance\_public\_dns) | Public DNS of manager instance (or DNS of EIP) |
| <a name="output_manager_instance_public_ip"></a> [manager\_instance\_public\_ip](#output\_manager\_instance\_public\_ip) | Public IP of manager instance (or EIP) |
| <a name="output_manager_instance_role_arn"></a> [manager\_instance\_role\_arn](#output\_manager\_instance\_role\_arn) | ARN of AWS IAM Role associated with manager instance |
| <a name="output_manager_instance_role_name"></a> [manager\_instance\_role\_name](#output\_manager\_instance\_role\_name) | Name of AWS IAM Role associated with manager instance |
| <a name="output_manager_instance_security_group_ids"></a> [manager\_instance\_security\_group\_ids](#output\_manager\_instance\_security\_group\_ids) | List of all security groups ID associated with manager instance |
| <a name="output_manager_instance_ssh_key_pair"></a> [manager\_instance\_ssh\_key\_pair](#output\_manager\_instance\_ssh\_key\_pair) | Name of the SSH key pair provisioned on manager instance |
| <a name="output_runner_instance_primary_security_group_id"></a> [runner\_instance\_primary\_security\_group\_id](#output\_runner\_instance\_primary\_security\_group\_id) | An ID of security group created for and associated with manager instance |
| <a name="output_runner_instance_role_arn"></a> [runner\_instance\_role\_arn](#output\_runner\_instance\_role\_arn) | ARN of AWS IAM Role associated with runner instance(s) |
| <a name="output_runner_instance_role_name"></a> [runner\_instance\_role\_name](#output\_runner\_instance\_role\_name) | Name of AWS IAM Role associated with runner instance(s) |
| <a name="output_s3_cache_bucket_arn"></a> [s3\_cache\_bucket\_arn](#output\_s3\_cache\_bucket\_arn) | Cache bucket ARN |
| <a name="output_s3_cache_bucket_id"></a> [s3\_cache\_bucket\_id](#output\_s3\_cache\_bucket\_id) | Cache bucket Name (aka ID) |

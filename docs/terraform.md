## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.0 |
| aws | ~> 2.12 |
| local | ~> 1.2 |
| null | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.12 |
| null | ~> 2.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_security\_groups | List of Security Group IDs allowed to be associated with manager instance | `list(string)` | `[]` | no |
| allowed\_metrics\_cidr\_blocks | CIDR blocks that should be able to access metrics port exposed on manager instance | <pre>list(object({<br>    cidr_blocks = list(string)<br>    description = string<br>  }))</pre> | `[]` | no |
| allowed\_ssh\_cidr\_blocks | CIDR blocks that should be able to communicate with manager's 22 port | <pre>list(object({<br>    cidr_blocks = list(string)<br>    description = string<br>  }))</pre> | `[]` | no |
| attributes | Additional attributes, e.g. `1` | `list(string)` | `[]` | no |
| authentication\_token\_ssm\_param | An override for SSM Parameter name that will store runner authentication token | `string` | `null` | no |
| authentication\_token\_ssm\_param\_kms\_key | Identifier of KMS key used for encryption of SSM Parameter that will store authentication token | `string` | `null` | no |
| availability\_zone | Availability Zone (e.g. `a`, `b`, `c` etc.) for instances to be launched in | `string` | `"a"` | no |
| cloudwatch\_logs\_kms\_key\_arn | The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested. | `string` | `null` | no |
| cloudwatch\_logs\_retention | Number of days you want to retain log events in Cloudwatch log group | `number` | `30` | no |
| create\_service\_linked\_roles | Defines whether required service-linked roles should be created | `bool` | `true` | no |
| delimiter | Delimiter to be used between `namespace`, `name`, `stage` and `attributes` | `string` | `"-"` | no |
| docker\_machine\_version | Docker machine version to be installed on manager instance | `string` | `"0.16.2-gitlab.2"` | no |
| enable\_access\_to\_ecr\_repositories | A list of ECR repositories in specified `region` that manager instance should have read-only access to | `list(string)` | `[]` | no |
| enable\_cloudwatch\_logs | Defines whether manager instance should ship its logs to Cloudwatch | `bool` | `true` | no |
| enable\_s3\_cache | Defines whether s3 should be created and used as a source for distributed cache | `bool` | `true` | no |
| enable\_ssm\_sessions | Defines whether access via SSM Session Manager should be enabled for manager instance | `bool` | `true` | no |
| gitlab\_runner\_version | Gitlab runner version to be installed on manager instance | `string` | `"13.2.0"` | no |
| gitlab\_url | Gitlab URL | `string` | `"https://gitlab.com"` | no |
| manager | Runners' manager (aka bastion) configuration | <pre>object({<br>    ami_id                      = string<br>    ami_owner                   = string<br>    instance_type               = string<br>    key_pair                    = string<br>    subnet_id                   = string<br>    associate_public_ip_address = bool<br>    assign_eip_address          = bool<br>    root_volume_size            = number<br>    ebs_optimized               = bool<br>    enable_detailed_monitoring  = bool<br>  })</pre> | n/a | yes |
| metrics\_port | See https://docs.gitlab.com/runner/monitoring/#configuration-of-the-metrics-http-server for more details | `number` | `9252` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | n/a | yes |
| namespace | Namespace (e.g. `cp` or `cloudposse`) | `string` | `""` | no |
| region | AWS Region identifier for instances to be launched in | `any` | n/a | yes |
| registration\_token | Runner registration token | `string` | `null` | no |
| registration\_token\_ssm\_param | SSM Parameter name that stored runner registration token. This parameter takes precedence over `registration_token` | `string` | `null` | no |
| registration\_token\_ssm\_param\_kms\_key | Identifier of KMS key used for encryption of SSM Parameter that stores registration token | `string` | `null` | no |
| runner | Gitlab runner configuration. See https://docs.gitlab.com/runner/configuration/advanced-configuration.html | <pre>object({<br>    concurrent = number<br>    limit      = number<br><br>    image = string<br>    tags  = list(string)<br><br>    use_private_address = bool<br>    instance_type       = string<br>    ami_id              = string<br><br>    run_untagged    = bool<br>    lock_to_project = bool<br><br>    idle = object({<br>      count = number<br>      time  = number<br>    })<br><br>    autoscaling_periods = list(object({<br>      periods    = list(string)<br>      idle_count = number<br>      idle_time  = number<br>      timezone   = string<br>    }))<br><br>    request_spot_instances = bool<br>    spot_bid_price         = number<br>    spot_block_duration    = number<br>  })</pre> | n/a | yes |
| runner\_advanced\_config | Advanced configuration options for gitlab runner | <pre>object({<br>    pre_build_script                  = string<br>    post_build_script                 = string<br>    pre_clone_script                  = string<br>    environment                       = list(string)<br>    request_concurrency               = number<br>    output_limit                      = number<br>    shm_size                          = number<br>    max_builds                        = number<br>    pull_policy                       = string<br>    additional_volumes                = list(string)<br>    additional_docker_machine_options = list(string)<br>    root_volume_size                  = number<br>    ebs_optimized                     = bool<br>    enable_detailed_monitoring        = bool<br>  })</pre> | <pre>{<br>  "additional_docker_machine_options": [],<br>  "additional_volumes": [<br>    "/certs/client"<br>  ],<br>  "ebs_optimized": false,<br>  "enable_detailed_monitoring": false,<br>  "environment": [],<br>  "max_builds": 0,<br>  "output_limit": 4096,<br>  "post_build_script": "",<br>  "pre_build_script": "",<br>  "pre_clone_script": "",<br>  "pull_policy": "always",<br>  "request_concurrency": 1,<br>  "root_volume_size": 20,<br>  "shm_size": 0<br>}</pre> | no |
| s3\_cache\_expiration | Number of days you want to retain cache in S3 bucket | `number` | `45` | no |
| s3\_cache\_infrequent\_access\_transition | Number of days to persist in the standard storage tier before moving to the infrequent access tier | `number` | `30` | no |
| stage | Stage (e.g. `prod`, `dev`, `staging`) | `string` | `""` | no |
| tags | Additional tags (e.g. `map(`BusinessUnit`,`XYZ`)` | `map(string)` | `{}` | no |
| vpc | VPC configuration | <pre>object({<br>    vpc_id     = string<br>    cidr_block = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| auth\_token\_ssm\_param\_arn | ARN of SSM Parameter that stores runner's authentication token |
| auth\_token\_ssm\_param\_name | Name of SSM Parameter that stores runner's authentication token |
| manager\_instance | Disambiguated ID of manager instance |
| manager\_instance\_cloudwatch\_alarm | CloudWatch Alarm ID created for manager instance |
| manager\_instance\_cloudwatch\_log\_group\_arn | ARN of CloudWatch Log Group created for manager instance |
| manager\_instance\_cloudwatch\_log\_group\_name | Name of CloudWatch Log Group created for manager instance |
| manager\_instance\_name | Manager instance name |
| manager\_instance\_policy\_arn | ARN of AWS IAM Policy associated with manager instance IAM role |
| manager\_instance\_policy\_name | Name of AWS IAM Policy associated with manager instance IAM role |
| manager\_instance\_primary\_security\_group\_id | An ID of security group created for and associated with manager instance |
| manager\_instance\_private\_dns | Private DNS of manager instance |
| manager\_instance\_private\_ip | Private IP of manager instance |
| manager\_instance\_public\_dns | Public DNS of manager instance (or DNS of EIP) |
| manager\_instance\_public\_ip | Public IP of manager instance (or EIP) |
| manager\_instance\_role\_arn | ARN of AWS IAM Role associated with manager instance |
| manager\_instance\_role\_name | Name of AWS IAM Role associated with manager instance |
| manager\_instance\_security\_group\_ids | List of all security groups ID associated with manager instance |
| manager\_instance\_ssh\_key\_pair | Name of the SSH key pair provisioned on manager instance |
| runner\_instance\_primary\_security\_group\_id | An ID of security group created for and associated with manager instance |
| runner\_instance\_role\_arn | ARN of AWS IAM Role associated with runner instance(s) |
| runner\_instance\_role\_name | Name of AWS IAM Role associated with runner instance(s) |
| s3\_cache\_bucket\_arn | Cache bucket ARN |
| s3\_cache\_bucket\_id | Cache bucket Name (aka ID) |

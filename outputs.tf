output "manager_instance_public_ip" {
  description = "Public IP of manager instance (or EIP)"
  value       = module.manager_instance.public_ip
}

output "manager_instance_private_ip" {
  description = "Private IP of manager instance"
  value       = module.manager_instance.private_ip
}

output "manager_instance_private_dns" {
  description = "Private DNS of manager instance"
  value       = module.manager_instance.private_dns
}

output "manager_instance_public_dns" {
  description = "Public DNS of manager instance (or DNS of EIP)"
  value       = module.manager_instance.public_dns
}

output "manager_instance" {
  description = "Disambiguated ID of manager instance"
  value       = module.manager_instance.id
}

output "manager_instance_name" {
  description = "Manager instance name"
  value       = module.manager_label.id
}

output "manager_instance_ssh_key_pair" {
  description = "Name of the SSH key pair provisioned on manager instance"
  value       = var.manager.key_pair
}

output "manager_instance_primary_security_group_id" {
  description = "An ID of security group created for and associated with manager instance"
  value       = aws_security_group.manager.id
}

output "manager_instance_security_group_ids" {
  description = "List of all security groups ID associated with manager instance"
  value       = module.manager_instance.security_group_ids
}

output "runner_instance_primary_security_group_id" {
  description = "An ID of security group created for and associated with manager instance"
  value       = aws_security_group.runners.id
}

output "manager_instance_role_name" {
  description = "Name of AWS IAM Role associated with manager instance"
  value       = module.manager_instance.role
}

output "manager_instance_role_arn" {
  description = "ARN of AWS IAM Role associated with manager instance"
  value       = "arn:${data.aws_partition.default.partition}:iam::${data.aws_caller_identity.default.account_id}:role/${module.manager_instance.role}"
}

output "runner_instance_role_name" {
  description = "Name of AWS IAM Role associated with runner instance(s)"
  value       = aws_iam_role.runner.name
}

output "runner_instance_role_arn" {
  description = "ARN of AWS IAM Role associated with runner instance(s)"
  value       = aws_iam_role.runner.arn
}

output "manager_instance_policy_name" {
  description = "Name of AWS IAM Policy associated with manager instance IAM role"
  value       = aws_iam_policy.manager.name
}

output "manager_instance_policy_arn" {
  description = "ARN of AWS IAM Policy associated with manager instance IAM role"
  value       = aws_iam_policy.manager.arn
}

output "manager_instance_cloudwatch_log_group_name" {
  description = "Name of CloudWatch Log Group created for manager instance"
  value       = join("", aws_cloudwatch_log_group.manager.*.name)
}

output "manager_instance_cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch Log Group created for manager instance"
  value       = join("", aws_cloudwatch_log_group.manager.*.arn)
}

output "manager_instance_cloudwatch_alarm" {
  description = "CloudWatch Alarm ID created for manager instance"
  value       = module.manager_instance.alarm
}

output "s3_cache_bucket_id" {
  description = "Cache bucket Name (aka ID)"
  value       = module.s3_cache_bucket.bucket_id
}

output "s3_cache_bucket_arn" {
  description = "Cache bucket ARN"
  value       = module.s3_cache_bucket.bucket_arn
}

output "auth_token_ssm_param_name" {
  description = "Name of SSM Parameter that stores runner's authentication token"
  value       = aws_ssm_parameter.authentication_token.name
}

output "auth_token_ssm_param_arn" {
  description = "ARN of SSM Parameter that stores runner's authentication token"
  value       = aws_ssm_parameter.authentication_token.arn
}

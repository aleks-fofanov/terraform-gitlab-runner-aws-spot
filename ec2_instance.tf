#############################################################
# Locals
#############################################################

locals {
  registration_token_in_ssm_param        = var.registration_token_ssm_param != null ? true : false
  registration_token_ssm_param_encrypted = var.registration_token_ssm_param_kms_key != null ? true : false
}

#############################################################
# Data sources
#############################################################

data "aws_ssm_parameter" "registration_token" {
  count = local.registration_token_in_ssm_param ? 1 : 0

  name = var.registration_token_ssm_param
}

data "aws_kms_key" "registration_token" {
  count = local.registration_token_in_ssm_param && local.registration_token_ssm_param_encrypted ? 1 : 0

  key_id = var.registration_token_ssm_param_kms_key
}

#############################################################
# Labels
#############################################################

module "manager_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.default_label.context
  attributes = compact(concat(var.attributes, ["manager"]))
}

module "runner_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.default_label.context
  attributes = compact(concat(var.attributes, ["runner"]))
}

#############################################################
# EC2 instances
#############################################################

module "manager_instance" {
  source  = "cloudposse/ec2-instance/aws"
  version = "0.30.4"

  attributes = compact(concat(var.attributes, ["manager"]))
  delimiter  = var.delimiter
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags

  security_groups               = compact(concat([aws_security_group.manager.id], var.additional_security_groups))
  create_default_security_group = false

  region                      = var.region
  vpc_id                      = var.vpc.vpc_id
  subnet                      = var.manager.subnet_id
  availability_zone           = data.aws_availability_zone.default.name
  assign_eip_address          = var.manager.assign_eip_address
  associate_public_ip_address = var.manager.associate_public_ip_address

  ami           = var.manager.ami_id
  ami_owner     = var.manager.ami_owner
  ssh_key_pair  = var.manager.key_pair
  instance_type = var.manager.instance_type

  monitoring = var.manager.enable_detailed_monitoring

  root_volume_size = var.manager.root_volume_size
  ebs_optimized    = var.manager.ebs_optimized

  user_data = local.manager_user_data_template_rendered
}

#############################################################
# IAM
#############################################################

resource "aws_iam_policy" "manager" {
  name        = module.manager_label.id
  description = "Controls access of gitlab runners manager to AWS Resources"
  path        = "/"
  policy      = module.aggregated_policy.result_document
}

resource "aws_iam_role_policy_attachment" "manager" {
  role       = module.manager_instance.role
  policy_arn = aws_iam_policy.manager.arn
}

module "aggregated_policy" {
  source  = "cloudposse/iam-policy-document-aggregator/aws"
  version = "0.8.0"

  source_documents = compact([
    data.aws_iam_policy_document.docker_machine.json,
    data.aws_iam_policy_document.authentication_token_ssm_param_permissions.json,
    join("", data.aws_iam_policy_document.authentication_token_kms_permissions.*.json),
    join("", data.aws_iam_policy_document.create_service_linked_roles.*.json),
    join("", data.aws_iam_policy_document.ssm_sessions.*.json),
    join("", data.aws_iam_policy_document.cache.*.json),
    join("", data.aws_iam_policy_document.ecr.*.json),
    join("", data.aws_iam_policy_document.registration_token_ssm_param_permissions.*.json),
    join("", data.aws_iam_policy_document.registration_token_kms_permissions.*.json),
  ])
}

// TODO: create proper minimal IAM policy for docker machine
// https://github.com/docker/machine/issues/1655

data "aws_iam_policy_document" "docker_machine" {
  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [aws_iam_role.runner.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeKeyPairs",
      "ec2:TerminateInstances",
      "ec2:StopInstances",
      "ec2:StartInstances",
      "ec2:RunInstances",
      "ec2:RebootInstances",
      "ec2:CreateKeyPair",
      "ec2:DeleteKeyPair",
      "ec2:ImportKeyPair",
      "ec2:Describe*",
      "ec2:CreateTags",
      "ec2:RequestSpotInstances",
      "ec2:CancelSpotInstanceRequests",
      "ec2:DescribeSubnets",
      "ec2:AssociateIamInstanceProfile"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_region.default.name]
      variable = "ec2:Region"
    }
  }
}

data "aws_iam_policy_document" "create_service_linked_roles" {
  count = var.create_service_linked_roles ? 0 : 1

  statement {
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["arn:aws:iam::${data.aws_caller_identity.default.account_id}:role/aws-service-role/*"]
  }
}

data "aws_iam_policy_document" "ssm_sessions" {
  count = var.enable_ssm_sessions ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cache" {
  count = var.enable_s3_cache ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:DeleteObject",
    ]
    resources = formatlist("${module.s3_cache_bucket.bucket_arn}%s", ["", "/*"])
  }
}

data "aws_iam_policy_document" "ecr" {
  count = length(var.enable_access_to_ecr_repositories) > 0 ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:ListTagsForResource",
    ]
    resources = var.enable_access_to_ecr_repositories
  }
}

data "aws_iam_policy_document" "authentication_token_ssm_param_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter"
    ]
    resources = [aws_ssm_parameter.authentication_token.arn]
  }
}

data "aws_iam_policy_document" "authentication_token_kms_permissions" {
  count = local.authentication_token_ssm_param_kms_key_provided ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [join("", data.aws_kms_key.authentication_token.*.arn)]
  }
}

data "aws_iam_policy_document" "registration_token_ssm_param_permissions" {
  count = local.registration_token_in_ssm_param ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]
    resources = [join("", data.aws_ssm_parameter.registration_token.*.arn)]
  }
}

data "aws_iam_policy_document" "registration_token_kms_permissions" {
  count = local.registration_token_ssm_param_encrypted ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [join("", data.aws_kms_key.registration_token.*.arn)]
  }
}

resource "aws_iam_role_policy_attachment" "manager_ssm_sessions" {
  count = var.enable_ssm_sessions ? 1 : 0

  role       = module.manager_instance.role
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "manager_cloudwatch_logs" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  role       = module.manager_instance.role
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy_document" "runner_assume" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "runner" {
  name               = module.runner_label.id
  description        = "Controls access of gitlab runners to AWS Resources"
  assume_role_policy = data.aws_iam_policy_document.runner_assume.json
}

resource "aws_iam_instance_profile" "runner" {
  name = module.runner_label.id
  role = aws_iam_role.runner.name
}

#############################################################
# Security Group
#############################################################

resource "aws_security_group" "manager" {
  vpc_id      = var.vpc.vpc_id
  name        = module.manager_label.id
  description = "Defines inbound and outbound rules for gitlab runners manager"

  tags = module.manager_label.tags
}

resource "aws_security_group_rule" "manager_egress" {
  security_group_id = aws_security_group.manager.id

  type             = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  description      = "Allow all egress"
}

resource "aws_security_group_rule" "manacache_s3_bucketger_ssh_from_allowed" {
  count = length(var.allowed_ssh_cidr_blocks)

  security_group_id = aws_security_group.manager.id

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.allowed_ssh_cidr_blocks[count.index].cidr_blocks
  description = var.allowed_ssh_cidr_blocks[count.index].description
}

resource "aws_security_group_rule" "manager_metrics_from_allowed" {
  count = length(var.allowed_metrics_cidr_blocks)

  security_group_id = aws_security_group.manager.id

  type        = "ingress"
  from_port   = var.metrics_port
  to_port     = var.metrics_port
  protocol    = "tcp"
  cidr_blocks = var.allowed_metrics_cidr_blocks[count.index].cidr_blocks
  description = var.allowed_metrics_cidr_blocks[count.index].description
}

resource "aws_security_group" "runners" {
  vpc_id      = var.vpc.vpc_id
  name        = module.runner_label.id
  description = "Defines inbound and outbound rules for gitlab runner instances spawned by manager"

  tags = module.runner_label.tags
}

resource "aws_security_group_rule" "runners_egress" {
  security_group_id = aws_security_group.runners.id

  type             = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  description      = "Allow all egress"
}

resource "aws_security_group_rule" "runners_icmp_from_vpc" {
  security_group_id = aws_security_group.runners.id

  type        = "ingress"
  from_port   = -1
  to_port     = -1
  protocol    = "icmp"
  cidr_blocks = [var.vpc.cidr_block]
  description = "Docker Machine, VPC"
}

resource "aws_security_group_rule" "runners_docker_machine_from_vpc" {
  security_group_id = aws_security_group.runners.id

  type        = "ingress"
  from_port   = 2376
  to_port     = 2376
  protocol    = "tcp"
  cidr_blocks = [var.vpc.cidr_block]
  description = "Docker Machine, VPC"
}

resource "aws_security_group_rule" "runners_ssh_from_vpc" {
  security_group_id = aws_security_group.runners.id

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [var.vpc.cidr_block]
  description = "SSH, VPC"
}

#############################################################
# Cloudwatch logs
#############################################################

resource "aws_cloudwatch_log_group" "manager" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name              = module.manager_label.id
  retention_in_days = var.cloudwatch_logs_retention
  kms_key_id        = var.cloudwatch_logs_kms_key_arn
  tags              = module.manager_label.tags
}

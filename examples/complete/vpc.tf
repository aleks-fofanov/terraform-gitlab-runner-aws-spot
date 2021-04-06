#############################################################
# VPC for gitlab runners
#############################################################

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "0.20.4"

  attributes = var.attributes
  delimiter  = var.delimiter
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags

  cidr_block = "10.200.0.0/16"
}

#############################################################
# Subnets
#############################################################

module "subnets" {
  source  = "cloudposse/multi-az-subnets/aws"
  version = "0.11.0"

  attributes = var.attributes
  delimiter  = var.delimiter
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags

  availability_zones = data.aws_availability_zones.aws_availability_zones.names

  type                = "public"
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.vpc.igw_id
  cidr_block          = module.vpc.vpc_cidr_block
  nat_gateway_enabled = false
}

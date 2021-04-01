#############################################################
# Labels
#############################################################

module "cache_bucket_label" {
  enabled = var.enable_s3_cache

  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.24.1"
  attributes = compact(concat(var.attributes, ["cache"]))
  delimiter  = var.delimiter
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags
}

#############################################################
# S3 Buckets
#############################################################

module "s3_cache_bucket" {
  enabled = var.enable_s3_cache

  source     = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=tags/0.32.0"
  attributes = compact(concat(var.attributes, ["cache"]))
  delimiter  = var.delimiter
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  tags       = var.tags

  user_enabled       = false
  versioning_enabled = false
  force_destroy      = true

  enable_glacier_transition = false
  expiration_days           = var.s3_cache_expiration
  standard_transition_days  = var.s3_cache_infrequent_access_transition
  lifecycle_rule_enabled    = true
}

#############################################################
# S3 Bucket public access
#############################################################

resource "aws_s3_bucket_public_access_block" "cache" {
  count = var.enable_s3_cache ? 1 : 0

  depends_on = [module.s3_cache_bucket]

  bucket = module.s3_cache_bucket.bucket_id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

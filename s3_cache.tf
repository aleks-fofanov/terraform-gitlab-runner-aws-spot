#############################################################
# S3 Buckets
#############################################################

module "s3_cache_bucket" {
  enabled = var.enable_s3_cache

  source  = "cloudposse/s3-bucket/aws"
  version = "0.33.0"

  context    = module.default_label.context
  attributes = compact(concat(var.attributes, ["cache"]))

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

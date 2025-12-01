resource "aws_s3_bucket" "manifests" {
  bucket        = "automation-setters-manifests-${local.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "manifests" {
  bucket                  = aws_s3_bucket.manifests.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

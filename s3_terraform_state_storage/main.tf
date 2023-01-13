provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "owner"   = "Lev Valuev"
      "manager" = "terraform"
    }
  }
}

resource "aws_kms_key" "this" {
  description             = "Key for state storage bucket encryption"
  deletion_window_in_days = "7"
  tags = {
    "Name" = "terraform state key"
  }
}

resource "aws_s3_bucket" "state_storage" {
  bucket = "terraform-state-storage-011223"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.state_storage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.this.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.state_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.state_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
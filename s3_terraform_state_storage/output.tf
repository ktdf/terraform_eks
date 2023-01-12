output "s3_state_storage" {
  description = "S3 bucket name. Will be used as a storage"
  value = aws_s3_bucket.state_storage.id
}

output "s3_state_storage_arn" {
  description = "S3 bucket arn. In case you need it (you don't)"
  value = aws_s3_bucket.state_storage.arn
}
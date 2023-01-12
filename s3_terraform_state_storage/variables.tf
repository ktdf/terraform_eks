variable "s3_bucket_name" {
  description = "Name of the s3bucket. Will be used as a terraform state storage"
  type = string
  default = "terraform-state-storage-011223"
}
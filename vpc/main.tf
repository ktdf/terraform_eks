terraform {
  backend "s3" {
    bucket = "terraform-state-storage-011223"
    key = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "owner" = "Lev Valuev"
      "provider" = "terraform"
    }
  }
}

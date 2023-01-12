terraform {
  backend "s3" {
    bucket = "terraform-state-storage-011223"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "owner"    = "Lev Valuev"
      "provider" = "terraform"
    }
  }
}

module "vpc" {
  source = "./vpc"

  cidr                = "172.16.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets     = ["172.16.1.0/24", "172.16.3.0/24"]
  public_subnets      = ["172.16.2.0/24", "172.16.4.0/24"]
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = 1 }
  public_subnet_tags  = { "kubernetes.io/role/elb" = 1 }
}
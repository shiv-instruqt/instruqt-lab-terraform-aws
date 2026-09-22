terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Lab         = "terraform-aws-fundamentals"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  name_prefix = "tf-lab-${var.bucket_suffix}"
}

resource "aws_s3_bucket" "lab" {
  bucket = local.name_prefix

  tags = {
    Name = local.name_prefix
  }
}

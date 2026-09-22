# Reference solution for Chapter 2.
# Replace <SUFFIX> with the value of $LAB_SUFFIX.

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
  region = "us-east-1"
}

resource "aws_s3_bucket" "lab" {
  bucket = "tf-lab-<SUFFIX>"

  tags = {
    Name      = "tf-lab-<SUFFIX>"
    Lab       = "terraform-aws-fundamentals"
    ManagedBy = "Terraform"
  }
}

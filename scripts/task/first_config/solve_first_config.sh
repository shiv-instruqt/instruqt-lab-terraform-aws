#!/usr/bin/env bash
set -euo pipefail
W="${WORKSPACE:-/workspace}"
SUFFIX="${LAB_SUFFIX:-demo}"
REGION="${AWS_REGION:-us-east-1}"
cd "${W}"

cat > main.tf <<EOF
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
  region = "${REGION}"
}

resource "aws_s3_bucket" "lab" {
  bucket = "tf-lab-${SUFFIX}"

  tags = {
    Name      = "tf-lab-${SUFFIX}"
    Lab       = "terraform-aws-fundamentals"
    ManagedBy = "Terraform"
  }
}
EOF

echo "Wrote ${W}/main.tf"

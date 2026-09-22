#!/usr/bin/env bash
set -euo pipefail
W="${WORKSPACE:-/workspace}"
SUFFIX="${LAB_SUFFIX:-demo}"
REGION="${AWS_REGION:-us-east-1}"
cd "${W}"

cat > variables.tf <<'EOF'
variable "aws_region" {
  type        = string
  description = "AWS region to deploy into."
  default     = "us-east-1"
}

variable "bucket_suffix" {
  type        = string
  description = "Unique suffix so the bucket name does not collide globally."
}

variable "environment" {
  type        = string
  description = "Environment name applied as a tag."
  default     = "training"
}
EOF

cat > main.tf <<'EOF'
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
EOF

cat > network.tf <<'EOF'
resource "aws_vpc" "lab" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_subnet" "lab" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "10.42.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${local.name_prefix}-subnet"
  }
}
EOF

cat > outputs.tf <<'EOF'
output "bucket_name" {
  value       = aws_s3_bucket.lab.id
  description = "Name of the S3 bucket created by this configuration."
}

output "vpc_id" {
  value       = aws_vpc.lab.id
  description = "ID of the VPC."
}

output "subnet_id" {
  value       = aws_subnet.lab.id
  description = "ID of the subnet."
}

output "region" {
  value       = var.aws_region
  description = "Region everything was deployed into."
}
EOF

cat > terraform.tfvars <<EOF
aws_region    = "${REGION}"
bucket_suffix = "${SUFFIX}"
environment   = "training"
EOF

terraform init -input=false -no-color >/dev/null
terraform apply -auto-approve -input=false -no-color

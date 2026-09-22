# ===========================================================================
# main.tf
#
# This file is intentionally almost empty - you are going to write it.
#
# Chapter 2 asks you to add two things:
#
#   1. A `terraform` block with a `required_providers` entry for
#      source = "hashicorp/aws", and a `provider "aws"` block with a region.
#
#   2. A resource block:  resource "aws_s3_bucket" "lab" { ... }
#      The bucket name must be globally unique, so end it with the value in
#      your $LAB_SUFFIX environment variable. Run `echo $LAB_BUCKET` in the
#      terminal to see the exact name to use.
#
# Delete these comments as you go - or leave them, Terraform does not mind.
# ===========================================================================

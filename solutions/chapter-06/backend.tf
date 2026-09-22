# Reference solution for Chapter 6.
# Replace <TF_STATE_BUCKET> with the value of $TF_STATE_BUCKET.
#
# Backend blocks cannot use variables or interpolation - every value must be
# a literal, because the backend is read before Terraform evaluates anything.

terraform {
  backend "s3" {
    bucket  = "<TF_STATE_BUCKET>"
    key     = "labs/terraform-aws-fundamentals/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    # Terraform 1.10+ supports S3-native state locking.
    # use_lockfile = true
  }
}

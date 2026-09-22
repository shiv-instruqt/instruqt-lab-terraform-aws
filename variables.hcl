# ---------------------------------------------------------------------------
# variables.hcl
# Tunable inputs for the lab. Change these in one place instead of hunting
# through the rest of the configuration.
# ---------------------------------------------------------------------------

variable "aws_region" {
  default     = "us-east-1"
  description = "AWS region used by the lab sandbox and by every learner Terraform configuration."
}

variable "terraform_version" {
  default     = "1.9.8"
  description = "Terraform CLI version installed on the workstation and used by the sandbox terraform resource."
}

variable "workstation_image" {
  default     = "ubuntu:24.04"
  description = "Base container image for the learner workstation. Swap for a prebuilt image to cut start-up time."
}

variable "workspace_dir" {
  default     = "/workspace"
  description = "Directory inside the workstation where the learner writes Terraform code."
}

variable "lab_tag" {
  default     = "terraform-aws-fundamentals"
  description = "Value applied as an AWS tag and used in resource naming so lab resources are easy to identify."
}

variable "enable_remote_state" {
  default     = true
  description = "When false, the sandbox skips pre-provisioning the S3 remote state bucket (Chapter 6 becomes read-only theory)."
}

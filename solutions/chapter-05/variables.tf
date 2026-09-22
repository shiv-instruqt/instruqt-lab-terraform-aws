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

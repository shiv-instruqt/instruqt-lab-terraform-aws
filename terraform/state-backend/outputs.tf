# Consumed by sandbox.hcl as:
#   resource.terraform.state_backend.output.bucket_name

output "bucket_name" {
  value       = aws_s3_bucket.state.id
  description = "Name of the S3 bucket that holds the learner's remote state."
}

output "bucket_arn" {
  value       = aws_s3_bucket.state.arn
  description = "ARN of the state bucket."
}

output "region" {
  value       = var.region
  description = "Region the state bucket lives in."
}

output "state_key" {
  value       = "labs/terraform-aws-fundamentals/terraform.tfstate"
  description = "Object key the learner should use for their state file."
}

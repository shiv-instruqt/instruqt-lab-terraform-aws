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

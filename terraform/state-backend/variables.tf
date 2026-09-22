variable "region" {
  type        = string
  description = "AWS region for the state bucket."
  default     = "us-east-1"
}

variable "suffix" {
  type        = string
  description = "Random suffix injected by Instruqt so bucket names are globally unique."
}

variable "lab" {
  type        = string
  description = "Lab identifier, applied as a tag."
  default     = "terraform-aws-fundamentals"
}

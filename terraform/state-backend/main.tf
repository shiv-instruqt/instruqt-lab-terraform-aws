# ---------------------------------------------------------------------------
# Author-side infrastructure, applied by the Instruqt `terraform` sandbox
# resource before the learner's session starts.
#
# It creates the versioned, encrypted S3 bucket that the learner migrates
# their Terraform state into during Chapter 6. Nothing here is visible to the
# learner except the bucket name, which arrives as $TF_STATE_BUCKET.
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "state" {
  bucket = "tf-lab-state-${var.suffix}"

  # The learner may leave state objects behind; let the sandbox tear down
  # cleanly regardless.
  force_destroy = true

  tags = {
    Name    = "tf-lab-state-${var.suffix}"
    Purpose = "Terraform remote state for the lab"
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

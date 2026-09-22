#!/usr/bin/env bash
set -euo pipefail
W="${WORKSPACE:-/workspace}"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"
BUCKET="${TF_STATE_BUCKET:-}"
cd "${W}"

if [ -z "${BUCKET}" ]; then
  echo "TF_STATE_BUCKET is empty - remote state was disabled for this lab." >&2
  exit 1
fi

cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket  = "${BUCKET}"
    key     = "labs/terraform-aws-fundamentals/terraform.tfstate"
    region  = "${REGION}"
    encrypt = true
  }
}
EOF

terraform init -migrate-state -force-copy -input=false -no-color
terraform apply -auto-approve -input=false -no-color

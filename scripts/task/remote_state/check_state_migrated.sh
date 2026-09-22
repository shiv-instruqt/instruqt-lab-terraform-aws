#!/usr/bin/env bash
# Passes when Terraform is actually using the S3 backend and the state object
# exists in the bucket.
set -uo pipefail
W="${WORKSPACE:-/workspace}"
BACKEND_STATE="${W}/.terraform/terraform.tfstate"

if [ ! -f "${BACKEND_STATE}" ]; then
  echo "Terraform has not been re-initialised yet."
  echo "Run: terraform init -migrate-state -force-copy"
  exit 1
fi

if ! jq -e '.backend.type == "s3"' "${BACKEND_STATE}" >/dev/null 2>&1; then
  echo "Terraform is still using the local backend."
  echo "Run: terraform init -migrate-state -force-copy"
  exit 1
fi

BUCKET="$(jq -r '.backend.config.bucket // empty' "${BACKEND_STATE}")"
KEY="$(jq -r '.backend.config.key // empty' "${BACKEND_STATE}")"

if [ -z "${BUCKET}" ] || [ -z "${KEY}" ]; then
  echo "The backend is configured but bucket/key could not be read."
  exit 1
fi

if ! aws s3api head-object --bucket "${BUCKET}" --key "${KEY}" >/dev/null 2>&1; then
  echo "No state object at s3://${BUCKET}/${KEY} yet."
  echo "Run: terraform init -migrate-state -force-copy   then   terraform apply"
  exit 1
fi

echo "State is stored remotely at s3://${BUCKET}/${KEY}."
exit 0

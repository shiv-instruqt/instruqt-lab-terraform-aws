#!/usr/bin/env bash
# Passes when the bucket Terraform thinks it created actually exists in AWS.
set -uo pipefail
W="${WORKSPACE:-/workspace}"
cd "${W}" || exit 1

# Prefer the name recorded in state, fall back to the conventional lab name.
BUCKET="$(terraform state show aws_s3_bucket.lab 2>/dev/null \
  | awk -F'=' '/^[[:space:]]*bucket[[:space:]]*=/ { gsub(/[" ]/, "", $2); print $2; exit }')"

if [ -z "${BUCKET}" ]; then
  BUCKET="$(terraform output -raw bucket_name 2>/dev/null)"
fi

if [ -z "${BUCKET}" ]; then
  BUCKET="tf-lab-${LAB_SUFFIX:-}"
fi

if [ -z "${BUCKET}" ] || [ "${BUCKET}" = "tf-lab-" ]; then
  echo "Could not work out which bucket to check. Has terraform apply run?"
  exit 1
fi

if ! aws s3api head-bucket --bucket "${BUCKET}" >/dev/null 2>&1; then
  echo "Bucket '${BUCKET}' was not found in AWS."
  echo "Check the output of terraform apply for errors, then try again."
  exit 1
fi

echo "Bucket '${BUCKET}' exists in AWS."
exit 0

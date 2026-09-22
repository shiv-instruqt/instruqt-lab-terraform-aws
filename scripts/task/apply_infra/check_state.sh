#!/usr/bin/env bash
# Passes when aws_s3_bucket.lab is tracked in Terraform state.
set -uo pipefail
cd "${WORKSPACE:-/workspace}" || exit 1

if ! terraform state list 2>/dev/null | grep -q '^aws_s3_bucket\.lab$'; then
  echo "aws_s3_bucket.lab is not in state yet."
  echo "Run: terraform apply   (or: terraform apply tfplan)"
  exit 1
fi

echo "State tracks aws_s3_bucket.lab."
exit 0

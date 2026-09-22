#!/usr/bin/env bash
# Passes when the learner has saved `terraform version` output to checks/terraform.txt
set -uo pipefail
W="${WORKSPACE:-/workspace}"
FILE="${W}/checks/terraform.txt"

if [ ! -f "${FILE}" ]; then
  echo "Could not find ${FILE}."
  echo "Run:  mkdir -p checks && terraform version | tee checks/terraform.txt"
  exit 1
fi

if ! grep -Eqi 'Terraform v[0-9]+\.[0-9]+\.[0-9]+' "${FILE}"; then
  echo "${FILE} exists but does not contain a Terraform version string."
  echo "Run:  terraform version | tee checks/terraform.txt"
  exit 1
fi

echo "Terraform version recorded."
exit 0

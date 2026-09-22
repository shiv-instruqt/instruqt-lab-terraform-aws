#!/usr/bin/env bash
# Passes once terraform init has downloaded the AWS provider.
set -uo pipefail
W="${WORKSPACE:-/workspace}"

if [ ! -d "${W}/.terraform" ]; then
  echo "No .terraform directory yet. Run: terraform init"
  exit 1
fi

if [ ! -f "${W}/.terraform.lock.hcl" ]; then
  echo "No .terraform.lock.hcl yet. Run: terraform init"
  exit 1
fi

if ! grep -q 'registry.terraform.io/hashicorp/aws' "${W}/.terraform.lock.hcl"; then
  echo "The lock file does not record the AWS provider."
  echo "Check that main.tf requires hashicorp/aws, then run: terraform init -upgrade"
  exit 1
fi

echo "Working directory initialised and the AWS provider is locked."
exit 0

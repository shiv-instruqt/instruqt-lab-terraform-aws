#!/usr/bin/env bash
set -euo pipefail
cd "${WORKSPACE:-/workspace}"
terraform init -input=false -no-color >/dev/null
terraform apply -auto-approve -input=false -no-color

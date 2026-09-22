#!/usr/bin/env bash
set -euo pipefail
cd "${WORKSPACE:-/workspace}"
terraform init -input=false -no-color >/dev/null
terraform plan -out=tfplan -input=false -no-color

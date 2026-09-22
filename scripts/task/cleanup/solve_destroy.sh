#!/usr/bin/env bash
set -euo pipefail
cd "${WORKSPACE:-/workspace}"
terraform destroy -auto-approve -input=false -no-color

#!/usr/bin/env bash
set -euo pipefail
W="${WORKSPACE:-/workspace}"
mkdir -p "${W}/checks"
cd "${W}"
terraform version | tee checks/terraform.txt

#!/usr/bin/env bash
set -euo pipefail
cd "${WORKSPACE:-/workspace}"
terraform init -input=false -no-color

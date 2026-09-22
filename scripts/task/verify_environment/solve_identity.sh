#!/usr/bin/env bash
set -euo pipefail
W="${WORKSPACE:-/workspace}"
mkdir -p "${W}/checks"
cd "${W}"
aws sts get-caller-identity | tee checks/identity.json

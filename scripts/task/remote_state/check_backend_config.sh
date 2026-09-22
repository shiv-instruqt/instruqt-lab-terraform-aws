#!/usr/bin/env bash
# Passes when backend.tf declares an S3 backend pointing at the lab bucket.
set -uo pipefail
W="${WORKSPACE:-/workspace}"
SRC="${W}/backend.tf"

if [ ! -f "${SRC}" ]; then
  echo "backend.tf does not exist. Create it in ${W}."
  exit 1
fi

NORM="$(sed -e 's/#.*$//' -e 's|//.*$||' "${SRC}" | tr '\n' ' ' | tr -s '[:space:]' ' ')"

if ! grep -Eq 'backend[[:space:]]+"s3"' <<<"${NORM}"; then
  echo "backend.tf must contain: terraform { backend \"s3\" { ... } }"
  exit 1
fi

if [ -n "${TF_STATE_BUCKET:-}" ] && ! grep -q "${TF_STATE_BUCKET}" <<<"${NORM}"; then
  echo "The backend block should point at bucket \"${TF_STATE_BUCKET}\"."
  echo "Run 'echo \$TF_STATE_BUCKET' to see it."
  exit 1
fi

if ! grep -Eq 'key[[:space:]]*=' <<<"${NORM}"; then
  echo "The backend block needs a key, for example key = \"labs/terraform.tfstate\"."
  exit 1
fi

if ! grep -Eq 'region[[:space:]]*=' <<<"${NORM}"; then
  echo "The backend block needs a region."
  exit 1
fi

echo "S3 backend is configured."
exit 0

#!/usr/bin/env bash
# Passes when main.tf declares aws_s3_bucket.lab with a unique bucket name.
set -uo pipefail
W="${WORKSPACE:-/workspace}"
SRC="${W}/main.tf"
SUFFIX="${LAB_SUFFIX:-}"

if [ ! -f "${SRC}" ]; then
  echo "main.tf does not exist in ${W}."
  exit 1
fi

NORM="$(sed -e 's/#.*$//' -e 's|//.*$||' "${SRC}" | tr '\n' ' ' | tr -s '[:space:]' ' ')"

if ! grep -Eq 'resource[[:space:]]+"aws_s3_bucket"[[:space:]]+"lab"' <<<"${NORM}"; then
  echo "Expected a block: resource \"aws_s3_bucket\" \"lab\" { ... }"
  exit 1
fi

if ! grep -Eq 'bucket[[:space:]]*=' <<<"${NORM}"; then
  echo "The aws_s3_bucket resource needs a bucket = \"...\" argument."
  exit 1
fi

# The name must be unique: either the literal suffix, or an interpolated
# variable / local / random value (which is what later chapters move to).
if [ -n "${SUFFIX}" ] && grep -q "${SUFFIX}" <<<"${NORM}"; then
  echo "Bucket name includes your unique lab suffix."
  exit 0
fi

if grep -Eq '\$\{?(var|local|random)' <<<"${NORM}"; then
  echo "Bucket name is built from a variable - good enough."
  exit 0
fi

echo "The bucket name must be globally unique. Include your suffix (${SUFFIX})."
echo "Run 'echo \$LAB_BUCKET' to see the exact name to use."
exit 1

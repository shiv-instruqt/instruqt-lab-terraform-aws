#!/usr/bin/env bash
# Passes when main.tf declares the hashicorp/aws provider and a provider block.
set -uo pipefail
W="${WORKSPACE:-/workspace}"
SRC="${W}/main.tf"

if [ ! -f "${SRC}" ]; then
  echo "main.tf does not exist in ${W}."
  exit 1
fi

# Strip comments and flatten to one line so formatting never matters.
NORM="$(sed -e 's/#.*$//' -e 's|//.*$||' "${SRC}" | tr '\n' ' ' | tr -s '[:space:]' ' ')"

if ! grep -q 'required_providers' <<<"${NORM}"; then
  echo "No required_providers block found. Add a terraform { required_providers { ... } } block."
  exit 1
fi

if ! grep -Eq '"hashicorp/aws"' <<<"${NORM}"; then
  echo "required_providers does not reference source = \"hashicorp/aws\"."
  exit 1
fi

if ! grep -Eq 'provider[[:space:]]+"aws"' <<<"${NORM}"; then
  echo "No provider \"aws\" block found."
  exit 1
fi

if ! grep -Eq 'region[[:space:]]*=' <<<"${NORM}"; then
  echo "The provider block needs a region, for example region = \"us-east-1\"."
  exit 1
fi

echo "AWS provider declared correctly."
exit 0

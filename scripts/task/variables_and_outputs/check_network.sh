#!/usr/bin/env bash
# Passes when a VPC and a subnet have been applied.
set -uo pipefail
cd "${WORKSPACE:-/workspace}" || exit 1

STATE="$(terraform state list 2>/dev/null)"

MISSING=""
grep -q '^aws_vpc\.lab$'    <<<"${STATE}" || MISSING="${MISSING} aws_vpc.lab"
grep -q '^aws_subnet\.lab$' <<<"${STATE}" || MISSING="${MISSING} aws_subnet.lab"

if [ -n "${MISSING}" ]; then
  echo "Not yet in state:${MISSING}"
  echo "Add them to network.tf and run: terraform apply"
  exit 1
fi

echo "VPC and subnet are applied."
exit 0

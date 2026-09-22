#!/usr/bin/env bash
# Passes when no AWS resources remain in Terraform state.
set -uo pipefail
cd "${WORKSPACE:-/workspace}" || exit 1

STATE="$(terraform state list 2>/dev/null || true)"
REMAINING="$(grep -c '^aws_' <<<"${STATE}" || true)"
REMAINING="${REMAINING:-0}"

if [ "${REMAINING}" -gt 0 ]; then
  echo "Terraform state still tracks ${REMAINING} AWS resource(s):"
  grep '^aws_' <<<"${STATE}" | sed 's/^/  /'
  echo
  echo "Run: terraform destroy"
  exit 1
fi

echo "Nothing left in state. Everything has been destroyed."
exit 0

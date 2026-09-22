#!/usr/bin/env bash
# Passes when terraform output returns non-empty bucket_name and vpc_id.
set -uo pipefail
cd "${WORKSPACE:-/workspace}" || exit 1

OUT="$(terraform output -json 2>/dev/null)"
if [ -z "${OUT}" ] || [ "${OUT}" = "{}" ]; then
  echo "terraform output returned nothing. Declare outputs in outputs.tf and re-apply."
  exit 1
fi

if ! jq -e '((.bucket_name.value // "") | tostring | length > 0)' <<<"${OUT}" >/dev/null 2>&1; then
  echo "Output 'bucket_name' is missing or empty."
  exit 1
fi

if ! jq -e '((.vpc_id.value // "") | tostring | length > 0)' <<<"${OUT}" >/dev/null 2>&1; then
  echo "Output 'vpc_id' is missing or empty."
  exit 1
fi

echo "Outputs look good:"
jq -r 'to_entries[] | "  \(.key) = \(.value.value)"' <<<"${OUT}"
exit 0

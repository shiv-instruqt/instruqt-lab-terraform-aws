#!/usr/bin/env bash
# Passes when variables.tf declares the three required input variables.
set -uo pipefail
W="${WORKSPACE:-/workspace}"
SRC="${W}/variables.tf"

if [ ! -f "${SRC}" ]; then
  echo "variables.tf does not exist. Create it in ${W}."
  exit 1
fi

NORM="$(sed -e 's/#.*$//' -e 's|//.*$||' "${SRC}" | tr '\n' ' ' | tr -s '[:space:]' ' ')"

MISSING=""
for v in aws_region bucket_suffix environment; do
  if ! grep -Eq "variable[[:space:]]+\"${v}\"" <<<"${NORM}"; then
    MISSING="${MISSING} ${v}"
  fi
done

if [ -n "${MISSING}" ]; then
  echo "variables.tf is missing these variable declarations:${MISSING}"
  exit 1
fi

echo "All three input variables are declared."
exit 0

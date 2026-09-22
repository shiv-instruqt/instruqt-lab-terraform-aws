#!/usr/bin/env bash
# Passes when a saved plan exists that would create at least one resource.
# Also passes if the learner has already applied, so the condition does not
# regress later in the lab.
set -uo pipefail
W="${WORKSPACE:-/workspace}"
cd "${W}" || exit 1

# Already applied? Then the plan step is behind us.
if terraform state list 2>/dev/null | grep -q '^aws_s3_bucket\.lab$'; then
  echo "Resources are already applied - plan step satisfied."
  exit 0
fi

if [ ! -f "${W}/tfplan" ]; then
  echo "No saved plan found. Run: terraform plan -out=tfplan"
  exit 1
fi

PLAN_JSON="$(terraform show -json tfplan 2>/dev/null)"
if [ -z "${PLAN_JSON}" ]; then
  echo "tfplan exists but could not be read. Regenerate it: terraform plan -out=tfplan"
  exit 1
fi

CREATES="$(jq '[.resource_changes[]? | select(.change.actions | index("create"))] | length' <<<"${PLAN_JSON}" 2>/dev/null)"
if [ -z "${CREATES}" ] || [ "${CREATES}" -lt 1 ]; then
  echo "The saved plan does not create anything. Make sure main.tf declares aws_s3_bucket.lab,"
  echo "then run: terraform plan -out=tfplan"
  exit 1
fi

echo "Saved plan would create ${CREATES} resource(s)."
exit 0

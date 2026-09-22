#!/usr/bin/env bash
# Passes when the learner has saved their AWS identity to checks/identity.json
set -uo pipefail
W="${WORKSPACE:-/workspace}"
FILE="${W}/checks/identity.json"

if [ ! -f "${FILE}" ]; then
  echo "Could not find ${FILE}."
  echo "Run:  aws sts get-caller-identity | tee checks/identity.json"
  exit 1
fi

if ! jq -e 'has("Account") and has("Arn") and has("UserId")' "${FILE}" >/dev/null 2>&1; then
  echo "${FILE} is not the JSON returned by 'aws sts get-caller-identity'."
  echo "Run:  aws sts get-caller-identity | tee checks/identity.json"
  exit 1
fi

echo "AWS identity recorded for account $(jq -r '.Account' "${FILE}")."
exit 0

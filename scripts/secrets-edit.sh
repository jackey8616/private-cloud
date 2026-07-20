#!/usr/bin/env bash
# Edit one AWS Secrets Manager secret in place: fetch -> $EDITOR -> push new version.
# This is the ongoing management path now that there is no local terraform.tfvars.json.
#
# Usage:
#   ./scripts/secrets-edit.sh <short-name>
# e.g.
#   ./scripts/secrets-edit.sh clode-claw
#   ./scripts/secrets-edit.sh cloudflare
set -euo pipefail

[[ $# -eq 1 ]] || {
  echo "usage: $0 <short-name>   (e.g. clode-claw, cloudflare, mongodbatlas)" >&2
  exit 1
}

NAME="$1"
REGION="ap-northeast-1"
FULL="private-cloud/${NAME}"

export AWS_SHARED_CREDENTIALS_FILE="${AWS_SHARED_CREDENTIALS_FILE:-.aws_credentials}"
export AWS_PROFILE="${AWS_PROFILE:-default}"

tmp="$(mktemp)"
chmod 600 "$tmp"
trap 'rm -f "$tmp"' EXIT

aws secretsmanager get-secret-value --secret-id "$FULL" --region "$REGION" \
  --query SecretString --output text | jq . >"$tmp"

before="$(shasum "$tmp")"
"${EDITOR:-vi}" "$tmp"
after="$(shasum "$tmp")"

if [[ "$before" == "$after" ]]; then
  echo "no changes; $FULL untouched."
  exit 0
fi

# Refuse to push invalid JSON.
jq -e . "$tmp" >/dev/null

aws secretsmanager put-secret-value --secret-id "$FULL" \
  --secret-string "file://$tmp" --region "$REGION" >/dev/null
echo "updated $FULL"

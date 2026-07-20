#!/usr/bin/env bash
# One-time migration: split terraform.tfvars.json into 13 AWS Secrets Manager
# secrets (region ap-northeast-1, same creds as the Terraform S3 backend).
# Idempotent: creates a secret if missing, otherwise stores a new version.
#
# The former "terraform-management" object is split by provider here; every other
# top-level object maps 1:1 to a secret. After a successful run you can delete the
# local terraform.tfvars.json — Terraform reads everything from Secrets Manager via
# the data sources in secrets.tf. For ongoing edits use scripts/secrets-edit.sh.
#
# Usage:
#   ./scripts/secrets-push.sh [path-to-tfvars.json]   # default: ./terraform.tfvars.json
set -euo pipefail

TFVARS="${1:-terraform.tfvars.json}"
REGION="ap-northeast-1"
PREFIX="private-cloud"

export AWS_SHARED_CREDENTIALS_FILE="${AWS_SHARED_CREDENTIALS_FILE:-.aws_credentials}"
export AWS_PROFILE="${AWS_PROFILE:-default}"

if [[ ! -f "$TFVARS" ]]; then
  echo "error: $TFVARS not found" >&2
  exit 1
fi

# push <short-name> <jq-filter>
# Extracts the value from $TFVARS via jq and stores it as private-cloud/<short-name>.
# The value is written to a 0600 temp file and passed via file:// so plaintext never
# appears in the process argument list (visible to `ps`).
push() {
  local name="$1" filter="$2"
  local full="${PREFIX}/${name}"
  local tmp
  tmp="$(mktemp)"
  chmod 600 "$tmp"
  jq -ce "$filter" "$TFVARS" >"$tmp"

  if aws secretsmanager describe-secret --secret-id "$full" --region "$REGION" >/dev/null 2>&1; then
    aws secretsmanager put-secret-value \
      --secret-id "$full" --secret-string "file://$tmp" --region "$REGION" >/dev/null
    echo "updated  $full"
  else
    aws secretsmanager create-secret \
      --name "$full" --secret-string "file://$tmp" --region "$REGION" >/dev/null
    echo "created  $full"
  fi

  rm -f "$tmp"
}

# terraform-management, split by provider + a shared "common" bucket.
push cloudflare   '{token: ."terraform-management"."cf-token", "account-id": ."terraform-management"."cf-account-id"}'
push linode       '{token: ."terraform-management"."linode-token"}'
push mongodbatlas '{"public-key": ."terraform-management"."mongodbatlas-public-key", "private-key": ."terraform-management"."mongodbatlas-private-key", "org-id": ."terraform-management"."mongodbatlas-org-id"}'
push github       '{token: ."terraform-management"."github-token"}'
push common       '{"often-login-ips": ."terraform-management"."often-login-ips"}'

# Per-app modules, 1:1.
push clode-tools  '."clode-tools"'
push pyfun        '."pyfun"'
push seeker       '."seeker"'
push fomo-bot     '."fomo-bot"'
push morpheus     '."morpheus"'
push groceries-nz '."groceries-nz"'
push silverfish   '."silverfish"'
push clode-claw   '."clode-claw"'

echo "done. ${TFVARS} -> AWS Secrets Manager (${REGION}). You can now delete ${TFVARS}."

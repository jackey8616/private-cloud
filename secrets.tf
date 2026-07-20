# All sensitive configuration lives in AWS Secrets Manager (region ap-northeast-1,
# the same account/credentials as the S3 state backend). Each secret is named
# "private-cloud/<name>" and holds a JSON string.
#
# Terraform only *reads* these — the plaintext never comes from a Terraform input,
# so there is no local terraform.tfvars.json anymore. Secrets are created/updated
# out-of-band by scripts/secrets-push.sh (migration) and scripts/secrets-edit.sh
# (ongoing edits), analogous to how .aws_credentials bootstraps the backend.
#
# The former root "terraform-management" catch-all is split here by provider
# (cloudflare / linode / mongodbatlas / github) plus a "common" bucket for the
# shared, non-provider often-login-ips list.
#
# jsondecode preserves the original hyphenated keys, so downstream references use
# bracket indexing (local.clode_tools["gcp-project-id"]) rather than attribute
# access — `local.x.gcp-project-id` would parse the hyphen as subtraction.

# --- provider credentials + shared config (was: terraform-management) ---

data "aws_secretsmanager_secret_version" "cloudflare" {
  secret_id = "private-cloud/cloudflare"
}

data "aws_secretsmanager_secret_version" "linode" {
  secret_id = "private-cloud/linode"
}

data "aws_secretsmanager_secret_version" "mongodbatlas" {
  secret_id = "private-cloud/mongodbatlas"
}

data "aws_secretsmanager_secret_version" "github" {
  secret_id = "private-cloud/github"
}

data "aws_secretsmanager_secret_version" "common" {
  secret_id = "private-cloud/common"
}

# --- per-app modules ---

data "aws_secretsmanager_secret_version" "clode_tools" {
  secret_id = "private-cloud/clode-tools"
}

data "aws_secretsmanager_secret_version" "pyfun" {
  secret_id = "private-cloud/pyfun"
}

data "aws_secretsmanager_secret_version" "seeker" {
  secret_id = "private-cloud/seeker"
}

data "aws_secretsmanager_secret_version" "fomo_bot" {
  secret_id = "private-cloud/fomo-bot"
}

data "aws_secretsmanager_secret_version" "morpheus" {
  secret_id = "private-cloud/morpheus"
}

data "aws_secretsmanager_secret_version" "groceries_nz" {
  secret_id = "private-cloud/groceries-nz"
}

data "aws_secretsmanager_secret_version" "silverfish" {
  secret_id = "private-cloud/silverfish"
}

data "aws_secretsmanager_secret_version" "clode_claw" {
  secret_id = "private-cloud/clode-claw"
}

locals {
  cloudflare   = jsondecode(data.aws_secretsmanager_secret_version.cloudflare.secret_string)
  linode       = jsondecode(data.aws_secretsmanager_secret_version.linode.secret_string)
  mongodbatlas = jsondecode(data.aws_secretsmanager_secret_version.mongodbatlas.secret_string)
  github       = jsondecode(data.aws_secretsmanager_secret_version.github.secret_string)
  common       = jsondecode(data.aws_secretsmanager_secret_version.common.secret_string)

  clode_tools  = jsondecode(data.aws_secretsmanager_secret_version.clode_tools.secret_string)
  pyfun        = jsondecode(data.aws_secretsmanager_secret_version.pyfun.secret_string)
  seeker       = jsondecode(data.aws_secretsmanager_secret_version.seeker.secret_string)
  fomo_bot     = jsondecode(data.aws_secretsmanager_secret_version.fomo_bot.secret_string)
  morpheus     = jsondecode(data.aws_secretsmanager_secret_version.morpheus.secret_string)
  groceries_nz = jsondecode(data.aws_secretsmanager_secret_version.groceries_nz.secret_string)
  silverfish   = jsondecode(data.aws_secretsmanager_secret_version.silverfish.secret_string)
  clode_claw   = jsondecode(data.aws_secretsmanager_secret_version.clode_claw.secret_string)
}

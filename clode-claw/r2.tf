locals {
  r2_permission_ids = [
    "bf7481a1826f439697cb59a20b22293e", # Workers R2 Storage Write
    "b4992e1108244f5d8bfbd5744320c2e1", # Workers R2 Storage Read"
  ]
  token_policies = [
    {
      effect            = "allow"
      permission_groups = [for id in local.r2_permission_ids : { id = id }]
      resources = jsonencode({
        "com.cloudflare.edge.r2.bucket.${var.cf-account-id}_default_${cloudflare_r2_bucket.laura-vault.name}" = "*"
      })
    }
  ]
}

resource "cloudflare_r2_bucket" "laura-vault" {
  account_id    = var.cf-account-id
  name          = "laura-vault"
  location      = "apac"
  storage_class = "Standard"
}

resource "cloudflare_account_token" "vps-token" {
  account_id = var.cf-account-id
  name       = "vps-token"
  policies   = local.token_policies
}

resource "cloudflare_account_token" "rowan-mba-token" {
  account_id = var.cf-account-id
  name       = "rowan-mba-token"
  policies   = local.token_policies
}
output "rowan_mba_secret_access_key" {
  value     = sha256(cloudflare_account_token.rowan-mba-token.value)
  sensitive = true
}
output "rowan_mba_access_key_id" {
  value     = cloudflare_account_token.rowan-mba-token.id
  sensitive = true
}

resource "cloudflare_account_token" "cld-iphone-token" {
  account_id = var.cf-account-id
  name       = "cld-iphone-token"
  policies   = local.token_policies
}
output "cld_iphone_secret_access_key" {
  value     = sha256(cloudflare_account_token.cld-iphone-token.value)
  sensitive = true
}
output "cld_iphone_access_key_id" {
  value     = cloudflare_account_token.cld-iphone-token.id
  sensitive = true
}

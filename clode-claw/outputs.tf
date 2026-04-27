output "clode-claw" {
  value = {
    instance = {
      public_ipv4 = tolist(linode_instance.openclaw_server.ipv4)[0]
      root_pass   = random_password.instance-password
    }
    credentials = {
      rowan_mba_access_key_id      = cloudflare_account_token.rowan-mba-token.id
      rowan_mba_secret_access_key  = sha256(cloudflare_account_token.rowan-mba-token.value)
      cld_iphone_access_key_id     = cloudflare_account_token.cld-iphone-token.id
      cld_iphone_secret_access_key = sha256(cloudflare_account_token.cld-iphone-token.value)
    }
  }
  sensitive = true
}

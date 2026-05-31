resource "cloudflare_zone" "clo5de-info" {
  account = {
    id = var.cf-account-id
  }
  name = "clo5de.info"
}

resource "cloudflare_dns_record" "toolman" {
  zone_id = cloudflare_zone.clo5de-info.id
  name    = "toolman"
  content = var.ip
  type    = "A"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "vpn" {
  zone_id = cloudflare_zone.clo5de-info.id
  name    = "vpn"
  content = var.vpn-ip
  type    = "A"
  proxied = false
  ttl     = 60
}

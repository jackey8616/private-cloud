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

resource "cloudflare_dns_record" "vpn-jp" {
  zone_id = cloudflare_zone.clo5de-info.id
  name    = "vpn-jp"
  content = var.vpn-jp-ip
  type    = "A"
  proxied = false
  ttl     = 60
}

# PROMA — two records, one box. **DNS only (gray cloud), and here that is a requirement rather
# than the habit the two records above follow:** Caddy on the instance gets its certificates from
# an HTTP-01 challenge, which is Let's Encrypt connecting to this IP on port 80. Proxied, the
# challenge would terminate at Cloudflare, and neither hostname would ever hold a certificate —
# while looking, from a browser, exactly like one that does.
#
# Short TTL because any configuration change replaces the instance (proma/instance.tf says why
# that is the accepted shape), and a new IP behind a day-long TTL is an outage nobody can shorten.
resource "cloudflare_dns_record" "proma" {
  zone_id = cloudflare_zone.clo5de-info.id
  name    = var.proma-webhook-hostname
  content = var.proma-ip
  type    = "A"
  proxied = false
  ttl     = 60
}

resource "cloudflare_dns_record" "proma-window" {
  zone_id = cloudflare_zone.clo5de-info.id
  name    = var.proma-window-hostname
  content = var.proma-ip
  type    = "A"
  proxied = false
  ttl     = 60
}

resource "cloudflare_dns_record" "knight-strike" {
  zone_id = cloudflare_zone.clo5de-info.id
  name    = "knight-strike"
  content = "jackey8616.github.io"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}


# silverfish.cc — managed in this module since dns/ already owns Cloudflare
# zones. Apex points at GitHub Pages (4 IPs); www / blog / morpheus / webmail
# are CNAMEs; mail goes through Gandi.
resource "cloudflare_zone" "silverfish-cc" {
  account = {
    id = var.cf-account-id
  }
  name = "silverfish.cc"
}

resource "cloudflare_dns_record" "silverfish-cc-apex" {
  for_each = toset([
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ])
  zone_id = cloudflare_zone.silverfish-cc.id
  name    = "silverfish.cc"
  content = each.value
  type    = "A"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "silverfish-cc-api" {
  zone_id = cloudflare_zone.silverfish-cc.id
  name    = "api.silverfish.cc"
  content = var.silverfish-backend-hostname
  type    = "CNAME"

  # DNS only (gray cloud), not proxied. Cloud Run uses a Google-managed cert
  # whose issuance requires Google's ACME validator to reach api.silverfish.cc
  # directly; with CF proxy on, the validator hits CF instead of GHS and the
  # cert is never provisioned. With gray cloud, the browser TLS terminates at
  # Cloud Run itself and Google's cert is valid for api.silverfish.cc.
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "silverfish-cc-www" {
  zone_id = cloudflare_zone.silverfish-cc.id
  name    = "www.silverfish.cc"
  content = "jackey8616.github.io"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "silverfish-cc-blog" {
  zone_id = cloudflare_zone.silverfish-cc.id
  name    = "blog.silverfish.cc"
  content = "blogs.vip.gandi.net"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "silverfish-cc-morpheus" {
  zone_id = cloudflare_zone.silverfish-cc.id
  name    = "morpheus.silverfish.cc"
  content = "morpheus-frontend-nine.vercel.app"
  type    = "CNAME"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "silverfish-cc-webmail" {
  zone_id = cloudflare_zone.silverfish-cc.id
  name    = "webmail.silverfish.cc"
  content = "webmail.gandi.net"
  type    = "CNAME"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "silverfish-cc-mx-spool" {
  zone_id  = cloudflare_zone.silverfish-cc.id
  name     = "silverfish.cc"
  content  = "spool.mail.gandi.net"
  type     = "MX"
  priority = 10
  proxied  = false
  ttl      = 1
}

resource "cloudflare_dns_record" "silverfish-cc-mx-fb" {
  zone_id  = cloudflare_zone.silverfish-cc.id
  name     = "silverfish.cc"
  content  = "fb.mail.gandi.net"
  type     = "MX"
  priority = 50
  proxied  = false
  ttl      = 1
}

resource "cloudflare_dns_record" "silverfish-cc-txt-google-verify" {
  zone_id = cloudflare_zone.silverfish-cc.id
  name    = "silverfish.cc"
  content = "\"google-site-verification=UZSrM5mrI0wEq9GdwD_TjXBwLt9pHV52_j9OzRSmRZQ\""
  type    = "TXT"
  proxied = false
  ttl     = 1
}

resource "cloudflare_dns_record" "silverfish-cc-txt-spf" {
  zone_id = cloudflare_zone.silverfish-cc.id
  name    = "silverfish.cc"
  content = "\"v=spf1 include:_mailcust.gandi.net ?all\""
  type    = "TXT"
  proxied = false
  ttl     = 1
}

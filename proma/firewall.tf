# **This is where PROMA's firewall stops looking like ClodeClaw's.** Every port on that box is
# restricted to often-login-ips because everything on it is for us; 80 and 443 here are open to
# the world because the sender is the LINE platform, which publishes no source range to allow.
#
# So the allowlist is not the control on the public endpoint — 來源證明 is (intake/delivery-origin.ts:
# a delivery that cannot prove the platform signed its bytes is answered exactly like an accepted
# one and dropped). 80 is open because Caddy's certificates come from an HTTP-01 challenge, which
# is Let's Encrypt connecting to this box on 80; closing it would leave both hostnames on an
# expired certificate 90 days later.
resource "linode_firewall" "proma" {
  label   = "proma-firewall"
  linodes = [linode_instance.proma.id]

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = var.allowed_connection_ips
  }

  inbound {
    label    = "allow-http-acme"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"
}

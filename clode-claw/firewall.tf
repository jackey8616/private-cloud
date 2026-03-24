resource "linode_firewall" "openclaw_sg_fw" {
  label = "openclaw-sg-firewall"
  linodes         = [linode_instance.openclaw_server.id]

  inbound {
    label    = "allow-ssh-taiwan"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = var.allowed_connection_ips
  }

  inbound {
    label    = "allow-ui-taiwan"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80,443"
    ipv4     = var.allowed_connection_ips
  }

  inbound_policy = "DROP"
  outbound_policy = "ACCEPT"
}

output "public_ipv4" {
  description = "Linode instance IPv4"
  value       = tolist(linode_instance.openclaw_server.ipv4)[0]
}

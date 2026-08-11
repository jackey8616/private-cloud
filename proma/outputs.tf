output "proma" {
  value = {
    instance = {
      public_ipv4 = tolist(linode_instance.proma.ipv4)[0]
      root_pass   = random_password.instance-password.result
    }
    hostnames = {
      webhook  = var.webhook-hostname
      window   = var.window-hostname
      callback = local.callback-url
    }
  }
  sensitive = true
}

output "public_ipv4" {
  description = "The instance's public IPv4, for the DNS module's two A records."
  value       = tolist(linode_instance.proma.ipv4)[0]
}

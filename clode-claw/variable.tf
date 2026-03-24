variable "ssh_public_keys" {
  description = "SSH public keys for login Instance"
  type = list(string)
  sensitive = true
}

variable "instance_root_password" {
  description = "Default Instance root password"
  type = string
  sensitive = true
}

variable "allowed_connection_ips" {
  description = "Allowed IPs to connect to instance"
  type = list(string)
}

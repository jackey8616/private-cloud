variable "cf-account-id" {
  type      = string
  sensitive = true
}

variable "ssh_public_keys" {
  description = "SSH public keys for login Instance"
  type        = list(string)
  sensitive   = true
}

variable "allowed_connection_ips" {
  description = "Allowed IPs to connect to instance"
  type        = list(string)
}

variable "instance-env" {
  type      = any
  sensitive = true
}

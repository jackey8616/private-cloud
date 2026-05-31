variable "cf-account-id" {
  type      = string
  sensitive = true
}

variable "ip" {
  type = string
}

variable "vpn-ip" {
  type = string
  sensitive = true
}

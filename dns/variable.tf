variable "cf-account-id" {
  type      = string
  sensitive = true
}

variable "ip" {
  type = string
}

variable "vpn-ip" {
  type      = string
  sensitive = true
}

variable "vpn-jp-ip" {
  type      = string
  sensitive = true
}

variable "silverfish-backend-hostname" {
  type        = string
  description = "Cloud Run hostname for the Silverfish backend (no protocol)."
}

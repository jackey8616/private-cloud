variable "gcp-project-id" {
  type = string
  sensitive = true
}

variable "gcp-billing-account" {
  type = string  
  sensitive = true
}

variable "region" {
  type    = string
  default = "asia-east1"
}

variable "zone" {
  type    = string
  default = "asia-east1-b"
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "use-spot" {
  type    = bool
  default = false
}

variable "vpn-username" {
  type = string
  sensitive = true
}

variable "vpn-password" {
  type = string
  sensitive = true
}

variable "vpn-psk" {
  type = string
  sensitive = true
}

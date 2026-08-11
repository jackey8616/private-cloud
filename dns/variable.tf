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

variable "proma-ip" {
  type        = string
  description = "Public IPv4 of the PROMA instance. Both PROMA records point at it."
}

variable "proma-webhook-hostname" {
  type        = string
  description = "FQDN the LINE platform posts 投遞 to. Sourced from a root local so the record, Caddy's certificate and the LINE console cannot drift apart."
}

variable "proma-window-hostname" {
  type        = string
  description = "FQDN 成員 open 案窗 on. Also the host half of LINE_LOGIN_CALLBACK_URL, which LINE compares byte for byte."
}

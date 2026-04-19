variable "cf-account-id" {
  type      = string
  sensitive = true
}

variable "ssh_public_keys" {
  description = "SSH public keys for login Instance"
  type        = list(string)
  sensitive   = true
}

variable "instance_root_password" {
  description = "Default Instance root password"
  type        = string
  sensitive   = true
}

variable "allowed_connection_ips" {
  description = "Allowed IPs to connect to instance"
  type        = list(string)
}

variable "instance-env" {
  type = object({
    agent_user         = string
    discord_bot_token  = string
    claude_oauth_token = string
    timezone           = string
    repo_url           = string
    gh_token           = optional(string, "")
  })
  sensitive = true
}

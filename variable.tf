variable "terraform-management" {
  type = object({
    cf-token                 = string
    cf-account-id            = string
    linode-token             = string
    often-login-ips          = list(string)
    mongodbatlas-public-key  = string
    mongodbatlas-private-key = string
    mongodbatlas-org-id      = string
  })
  sensitive = true
}

variable "clode-tools" {
  type = object({
    gcp-project-id      = string
    gcp-billing-account = string
    vpn-username        = string
    vpn-password        = string
    vpn-psk             = string
    use-spot            = bool
  })
  sensitive = true
}


variable "pyfun" {
  type = object({
    aws-ecr-image-sha = string
    aws-cert-key-path = string
    aws-cert-pem-path = string
  })
  sensitive = true
}


variable "seeker" {
  type = object({
    gcp-project-id      = string
    gcp-billing-account = string
  })
  sensitive = true
}


variable "fomo-bot" {
  type = object({
    gcp-project-id      = string
    gcp-billing-account = string
  })
  sensitive = true
}


variable "morpheus" {
  type = object({
    gcp-project-id      = string
    gcp-billing-account = string
  })
  sensitive = true
}


variable "groceries-nz" {
  type = object({
    aws-ecr-image-sha     = string
    lambda-env-postgresql = string
  })
  sensitive = true
}


variable "silverfish" {
  type = object({
    db-password         = string
    gcp-project-id      = string
    gcp-billing-account = string
  })
  sensitive = true
}


variable "clode-claw" {
  type = object({
    instance-env = object({
      agent_user         = string
      discord_bot_token  = string
      claude_oauth_token = string
      ollama_api_key     = string
      hermes_image       = string
      timezone           = string
      repo_url           = string
      gh_token           = optional(string, "")
    })
  })
  sensitive = true
}

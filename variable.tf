variable "terraform-management" {
  type = object({
    cf-token        = string
    cf-account-id   = string
    linode-token    = string
    often-login-ips = list(string)
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


variable "clode-claw" {
  type = object({
    instance-default-root-password = string
    instance-env = object({
      agent_user         = string
      discord_bot_token  = string
      claude_oauth_token = string
      timezone           = string
      repo_url           = string
      gh_token           = optional(string, "")
    })
  })
  sensitive = true
}

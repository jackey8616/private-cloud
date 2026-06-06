variable "github-org-name" {
  type        = string
  description = "GitHub organization or user name (owner of the managed repos)"
}

variable "github-token" {
  type        = string
  description = "GitHub PAT (scope: repo) used by the integrations/github provider."
  sensitive   = true
}

variable "repository-variables" {
  type        = map(map(string))
  default     = {}
  description = "Outer key: GitHub repo name. Inner: variable name (will be prefixed with TF_) → value."
}

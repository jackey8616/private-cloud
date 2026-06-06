variable "atlas-org-id" {
  type        = string
  description = "MongoDB Atlas Organization ID that owns the Silverfish project"
}

variable "allow-ips" {
  type        = list(string)
  description = "CIDRs allowed to connect to the Atlas cluster (home/office IPs for migration, plus future Cloud Run egress)"
}

variable "gcp-project-id" {
  type        = string
  description = "GCP project id that hosts the Silverfish backend"
}

variable "gcp-billing-account" {
  type        = string
  description = "Billing account id linked to the GCP project"
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}

variable "allow-origins" {
  type        = string
  description = "JSON-encoded array of allowed CORS origins for the backend."
  default     = "[\"https://silverfish.cc\"]"
}

variable "crawl-duration" {
  type        = number
  description = "Minutes between content re-crawls."
  default     = 60
}

variable "github-oidc-pool-name" {
  type        = string
  description = "Full resource name of the shared GitHub WIF pool (from module.GitHubOIDC.pool-name)"
}

variable "github-org-name" {
  type        = string
  description = "GitHub organization or user that owns Silverfish-Backend"
}

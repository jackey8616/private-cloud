variable "manage-gcp-project-id" {
  type        = string
  description = "GCP project that hosts the Workload Identity Pool"
  sensitive   = true
}

variable "github-org-name" {
  type        = string
  description = "GitHub organization or user that owns the consuming repositories"
}

variable "atlas-org-id" {
  type        = string
  description = "MongoDB Atlas Organization ID that owns the Silverfish project"
}

variable "db-password" {
  type        = string
  description = "Password for the silverfish database user"
  sensitive   = true
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

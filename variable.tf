variable "cf-token" {
  type      = string
  sensitive = true
}

variable "linode-token" {
  type      = string
  sensitive = true
}
variable "often-login-ips" {
  type = list(string)
  default = [
    "61.224.194.18/32"
  ]
}


variable "pyfun-aws-ecr-image-sha" {
  type = string
}
variable "pyfun-aws-cert-key-path" {
  type = string
}
variable "pyfun-aws-cert-pem-path" {
  type = string
}


variable "seeker-gcp-project-id" {
  type        = string
  description = "GCP project id for Seeker"
}
variable "seeker-gcp-billing-account" {
  type        = string
  description = "Billing Account id of GCP project Seeker"
}


variable "fomo-bot-gcp-project-id" {
  type        = string
  description = "GCP project id for FomoBot"
}

variable "fomo-bot-gcp-billing-account" {
  type        = string
  description = "Billing Account id of GCP project FomoBot"
}


variable "morpheus-gcp-project-id" {
  type        = string
  description = "GCP project id for Morpheus"
}
variable "morpheus-gcp-billing-account" {
  type        = string
  description = "Billing Account id of GCP project Morpheus"
}


variable "groceries-nz-aws-ecr-image-sha" {
  type        = string
  description = "Image SHA in ECR"
}

variable "groceries-nz-lambda-env-postgresql" {
  type        = string
  description = "PostgreSQL URI for Lambda environment variable"
  sensitive   = true
}


variable "clode-claw-instance-default-root-password" {
  type        = string
  description = "Default Instance root password"
  sensitive   = true
}

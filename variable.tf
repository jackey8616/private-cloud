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

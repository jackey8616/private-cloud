terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.34.0"
    }
  }
}

provider "google" {
  project = var.gcp-project-id
  region  = var.region
  zone    = var.zone
}

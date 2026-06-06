terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.18"
    }

    google = {
      source  = "hashicorp/google"
      version = "7.34.0"
    }
  }
}

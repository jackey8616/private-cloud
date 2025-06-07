resource "google_storage_bucket" "morpheus-artifact" {
  project  = google_project.morpheus.project_id
  name     = "morpheus-artifact"
  location = "US-EAST1"
}

resource "google_storage_bucket" "morpheus-artifact-develop" {
  project  = google_project.morpheus.project_id
  name     = "morpheus-artifact-develop"
  location = "US-EAST1"
}

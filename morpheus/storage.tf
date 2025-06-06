resource "google_storage_bucket" "morpheus-artifact" {
  project = google_project.morpheus.project_id
  name = "morpheus-artifact"
  location = "US-EAST1"
}

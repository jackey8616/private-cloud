resource "google_service_account" "seeker-service-account" {
  project = google_project.seeker.project_id
  account_id = "seeker-linode"
  display_name = "Seeker-Linode"
  description = "Seeker service account for which on LinodeVPC"
}

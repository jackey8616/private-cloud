resource "google_service_account" "morpheus-service-account" {
  project      = google_project.morpheus.project_id
  account_id   = "morpheus-linode"
  display_name = "Morpheus-Linode"
  description  = "Morpheus service account for which on LinodeVPC"
}

resource "google_service_account" "morpheus-service-account-develop" {
  project      = google_project.morpheus.project_id
  account_id   = "morpheus-develop"
  display_name = "Morpheus-Develop"
  description  = "Morpheus service account for which on Develop"
}

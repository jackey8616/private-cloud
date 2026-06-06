resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
  ])
  project = google_project.silverfish.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_artifact_registry_repository" "silverfish" {
  project       = google_project.silverfish.project_id
  location      = var.region
  repository_id = "silverfish-backend"
  format        = "DOCKER"
  description   = "Container images for the silverfish-backend service"

  depends_on = [google_project_service.apis]
}

resource "google_service_account" "cloud-run" {
  project      = google_project.silverfish.project_id
  account_id   = "silverfish-backend-run"
  display_name = "Silverfish-Backend Cloud Run"
  description  = "Runtime identity for the silverfish-backend Cloud Run service"

  depends_on = [google_project_service.apis]
}

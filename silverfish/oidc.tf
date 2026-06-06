resource "google_service_account" "github-actions" {
  project      = google_project.silverfish.project_id
  account_id   = "silverfish-backend-gha"
  display_name = "Silverfish-Backend GitHub Actions"
  description  = "Impersonated by GitHub Actions to build, push, and deploy"

  depends_on = [google_project_service.apis]
}

# Workflows from <org>/Silverfish-Backend can impersonate the GHA SA. The
# shared github-oidc pool's attribute_condition already restricts the issuer
# to var.github-org-name.
resource "google_service_account_iam_member" "github-actions-wif" {
  service_account_id = google_service_account.github-actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.github-oidc-pool-name}/attribute.repository/${var.github-org-name}/Silverfish-Backend"
}

resource "google_artifact_registry_repository_iam_member" "github-actions-ar-writer" {
  project    = google_project.silverfish.project_id
  location   = google_artifact_registry_repository.silverfish.location
  repository = google_artifact_registry_repository.silverfish.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github-actions.email}"
}

# Deploy new Cloud Run revisions. The service shape (env, secrets, IAM) is
# Terraform-managed; this SA only rolls over the image, so run.developer is
# sufficient.
resource "google_project_iam_member" "github-actions-run-developer" {
  project = google_project.silverfish.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.github-actions.email}"
}

resource "google_service_account_iam_member" "github-actions-uses-runtime" {
  service_account_id = google_service_account.cloud-run.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github-actions.email}"
}

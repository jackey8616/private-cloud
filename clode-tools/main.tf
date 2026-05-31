resource "google_project" "clode-tools" {
  billing_account = var.gcp-billing-account
  name            = "Clode-Tools"
  project_id      = var.gcp-project-id
}

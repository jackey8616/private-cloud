resource "google_project" "morpheus" {
  billing_account = var.gcp-billing-account
  name            = "Morpheus"
  project_id      = var.gcp-project-id
}

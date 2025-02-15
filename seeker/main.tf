resource "google_project" "seeker" {
  billing_account = var.gcp-billing-account
  name            = "Seeker"
  project_id      = var.gcp-project-id
}

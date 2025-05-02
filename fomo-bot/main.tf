resource "google_project" "fomo-bot" {
  billing_account = var.gcp-billing-account 
  name = "FomoBot"
  project_id = var.gcp-project-id
}

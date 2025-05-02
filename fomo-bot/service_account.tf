resource "google_service_account" "fomo-bot-service-account" {
  project      = google_project.fomo-bot.project_id
  account_id   = "fomo-bot-linode"
  display_name = "FomoBot-Linode"
  description  = "FomoBot service account for which on LinodeVPC"
}

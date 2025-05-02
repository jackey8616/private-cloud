resource "google_project_iam_custom_role" "vertex_predictor" {
  project     = google_project.fomo-bot.project_id
  role_id     = "vertex_ai_predictor"
  title       = "VertexAI Predictor"
  description = "Allows only VertexAI prediction(prompt execution)"
  permissions = [
    "aiplatform.endpoints.predict"
  ]
}

resource "google_project_iam_binding" "vertex_ai_predictor_binding" {
  project = google_project.fomo-bot.project_id
  role    = google_project_iam_custom_role.vertex_predictor.name
  members = [
    "serviceAccount:${google_service_account.fomo-bot-service-account.email}",
  ]
}

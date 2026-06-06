# DB_PASSWORD is the source of truth for the Atlas user password. Terraform
# creates the container, the user populates the value once via:
#   gcloud secrets versions add DB_PASSWORD --project=<project_id> --data-file=-
# Subsequent applies read the latest version, reconcile the Atlas user, and
# rewrite DB_HOST in lockstep.
resource "google_secret_manager_secret" "db-password" {
  project   = google_project.silverfish.project_id
  secret_id = "DB_PASSWORD"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

data "google_secret_manager_secret_version" "db-password" {
  secret  = google_secret_manager_secret.db-password.id
  version = "latest"
}

# DB_HOST is derived from the Atlas SRV connection string plus the database
# user credentials read from DB_PASSWORD. A tf apply rotates DB_HOST in
# lockstep with any Atlas change — cluster rename, password rotation, etc.
locals {
  atlas_host = trimprefix(mongodbatlas_advanced_cluster.silverfish.connection_strings[0].standard_srv, "mongodb+srv://")
  db_uri     = "mongodb+srv://${mongodbatlas_database_user.silverfish.username}:${data.google_secret_manager_secret_version.db-password.secret_data}@${local.atlas_host}/?retryWrites=true&w=majority"
}

resource "google_secret_manager_secret" "db-host" {
  project   = google_project.silverfish.project_id
  secret_id = "DB_HOST"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "db-host" {
  secret      = google_secret_manager_secret.db-host.id
  secret_data = local.db_uri
}

# RECAPTCHA_KEY and HASH_SALT predate Terraform — they live in Render today.
# Terraform creates the empty containers + IAM, you populate the values once via
#   gcloud secrets versions add <name> --project=<project_id> --data-file=-
# so sensitive values never enter Terraform state.

resource "google_secret_manager_secret" "recaptcha-key" {
  project   = google_project.silverfish.project_id
  secret_id = "RECAPTCHA_KEY"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret" "hash-salt" {
  project   = google_project.silverfish.project_id
  secret_id = "HASH_SALT"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_iam_member" "cloud-run-can-read" {
  for_each = {
    db-host       = google_secret_manager_secret.db-host.id
    recaptcha-key = google_secret_manager_secret.recaptcha-key.id
    hash-salt     = google_secret_manager_secret.hash-salt.id
  }
  project   = google_project.silverfish.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud-run.email}"
}

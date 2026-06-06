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

# Cloud Run service "shape" owned by Terraform: env vars, secret mounts,
# scaling, runtime SA, public IAM. The image is initialized to GCP's
# placeholder and then managed by the GitHub Actions workflow via
# 'gcloud run services update --image=...' on each v* tag push.
# lifecycle.ignore_changes prevents Terraform from fighting the workflow.
resource "google_cloud_run_v2_service" "silverfish" {
  project  = google_project.silverfish.project_id
  location = var.region
  name     = "silverfish-backend"

  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account = google_service_account.cloud-run.email
    timeout         = "300s"
    scaling {
      min_instance_count = 0
      max_instance_count = 5
    }
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      ports {
        container_port = 8080
      }
      resources {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }
      env {
        name  = "DEBUG"
        value = "false"
      }
      env {
        name  = "SSL"
        value = "false"
      }
      env {
        name  = "ALLOW_ORIGINS"
        value = var.allow-origins
      }
      env {
        name  = "CRAWL_DURATION"
        value = tostring(var.crawl-duration)
      }
      env {
        name = "DB_HOST"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db-host.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "HASH_SALT"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.hash-salt.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "RECAPTCHA_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.recaptcha-key.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version,
    ]
  }

  depends_on = [google_secret_manager_secret_iam_member.cloud-run-can-read]
}

# Custom domain mapping so Cloud Run accepts requests with Host: api.silverfish.cc.
# Without this, a CF-proxied CNAME from api.silverfish.cc to *.run.app returns
# 404 because Cloud Run multi-tenancy uses the Host header to route between
# services. After apply, the mapping exposes a status.resource_records[0]
# rrdata (typically ghs.googlehosted.com) that the dns/ module uses as the
# CNAME target on Cloudflare.
#
# REQUIRES: silverfish.cc must be verified for the GCP account running TF in
# Google Search Console. The zone already has a google-site-verification TXT;
# if it's not for the right account, this resource will fail with
# DOMAIN_OWNERSHIP_REQUIRED — verify at https://search.google.com/search-console.
resource "google_cloud_run_domain_mapping" "silverfish-api" {
  name     = "api.silverfish.cc"
  location = var.region

  metadata {
    namespace = google_project.silverfish.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.silverfish.name
  }
}

# Public — the API is intended to be hit by browsers.
resource "google_cloud_run_v2_service_iam_member" "public-invoker" {
  project  = google_cloud_run_v2_service.silverfish.project
  location = google_cloud_run_v2_service.silverfish.location
  name     = google_cloud_run_v2_service.silverfish.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

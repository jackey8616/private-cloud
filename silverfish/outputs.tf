output "silverfish" {
  value = {
    atlas = {
      project_id   = mongodbatlas_project.silverfish.id
      cluster_name = mongodbatlas_advanced_cluster.silverfish.name
      db_user      = mongodbatlas_database_user.silverfish.username
      uri_standard = mongodbatlas_advanced_cluster.silverfish.connection_strings[0].standard
      uri_srv      = mongodbatlas_advanced_cluster.silverfish.connection_strings[0].standard_srv
    }
    backend = {
      project_id            = google_project.silverfish.project_id
      region                = var.region
      artifact_registry_url = "${var.region}-docker.pkg.dev/${google_project.silverfish.project_id}/${google_artifact_registry_repository.silverfish.repository_id}"
      runtime_sa            = google_service_account.cloud-run.email
      service_url           = google_cloud_run_v2_service.silverfish.uri
      populate_secrets = [
        "echo -n '<DB_PASSWORD value>'   | gcloud secrets versions add DB_PASSWORD   --project=${google_project.silverfish.project_id} --data-file=-",
        "echo -n '<RECAPTCHA_KEY value>' | gcloud secrets versions add RECAPTCHA_KEY --project=${google_project.silverfish.project_id} --data-file=-",
        "echo -n '<HASH_SALT value>'     | gcloud secrets versions add HASH_SALT     --project=${google_project.silverfish.project_id} --data-file=-",
      ]
    }
    oidc = {
      gha_sa_email = google_service_account.github-actions.email
    }
  }
  sensitive = true
}

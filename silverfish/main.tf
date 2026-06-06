resource "google_project" "silverfish" {
  name            = "Silverfish"
  project_id      = var.gcp-project-id
  billing_account = var.gcp-billing-account
}

resource "mongodbatlas_project" "silverfish" {
  name   = "Silverfish"
  org_id = var.atlas-org-id
}

resource "mongodbatlas_advanced_cluster" "silverfish" {
  project_id   = mongodbatlas_project.silverfish.id
  name         = "silverfish"
  cluster_type = "REPLICASET"

  replication_specs {
    region_configs {
      provider_name         = "TENANT"
      backing_provider_name = "AWS"
      region_name           = "AP_NORTHEAST_1"
      priority              = 7

      electable_specs {
        instance_size = "M0"
      }
    }
  }
}

resource "mongodbatlas_database_user" "silverfish" {
  project_id         = mongodbatlas_project.silverfish.id
  username           = "silverfish"
  password           = data.google_secret_manager_secret_version.db-password.secret_data
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "silverfish"
  }
}

resource "mongodbatlas_project_ip_access_list" "allow" {
  for_each   = toset(nonsensitive(var.allow-ips))
  project_id = mongodbatlas_project.silverfish.id
  cidr_block = each.value
}

output "silverfish" {
  value = {
    project_id   = mongodbatlas_project.silverfish.id
    cluster_name = mongodbatlas_advanced_cluster.silverfish.name
    db_user      = mongodbatlas_database_user.silverfish.username
    uri_standard = mongodbatlas_advanced_cluster.silverfish.connection_strings[0].standard
    uri_srv      = mongodbatlas_advanced_cluster.silverfish.connection_strings[0].standard_srv
  }
  sensitive = true
}

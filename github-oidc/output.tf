output "pool-name" {
  value = google_iam_workload_identity_pool.github.name
}

output "provider-name" {
  value = google_iam_workload_identity_pool_provider.github.name
}

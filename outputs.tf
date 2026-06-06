output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
}

output "clode-claw" {
  value     = module.ClodeClaw.clode-claw
  sensitive = true
}

output "clode-tools" {
  value     = module.Clode-Tools.clode-tools
  sensitive = true
}

output "silverfish" {
  value = merge(
    module.Silverfish.silverfish,
    {
      oidc = merge(
        module.Silverfish.silverfish.oidc,
        {
          workload_identity_provider = module.GitHubOIDC.provider-name
        }
      )
    }
  )
  sensitive = true
}

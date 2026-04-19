output "bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state_lock.name
}

output "rowan_mba_secret_access_key" {
  value     = module.ClodeClaw.rowan_mba_secret_access_key
  sensitive = true
}
output "rowan_mba_access_key_id" {
  value     = module.ClodeClaw.rowan_mba_access_key_id
  sensitive = true
}
output "cld_iphone_secret_access_key" {
  value     = module.ClodeClaw.cld_iphone_secret_access_key
  sensitive = true
}
output "cld_iphone_access_key_id" {
  value     = module.ClodeClaw.cld_iphone_access_key_id
  sensitive = true
}

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

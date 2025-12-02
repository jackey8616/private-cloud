resource "aws_ecr_repository" "GroceriesNZ-Lambda" {
  name = "groceries-nz-lambda"

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_s3_bucket" "groceries-ingestion-data" {
  bucket = "groceries-ingestion-data"
  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_s3_bucket_cors_configuration" "groceries-ingestion-data" {
  bucket = aws_s3_bucket.groceries-ingestion-data.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_origins = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    expose_headers = ["ETag"]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "groceries-ingestion-data" {
  bucket = aws_s3_bucket.groceries-ingestion-data.id

  rule {
    id = "rule-01"

    filter {}

    expiration {
      days = 7
    }

    status = "Enabled"
  }
}

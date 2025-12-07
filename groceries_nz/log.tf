resource "aws_cloudwatch_log_group" "single_store_ingestion_sfn_log_group" {
  name = "/aws/step-functions/SingleStoreIngestion"
  retention_in_days = 14

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_log_group" "fetch_rank_stores_ingestion_sfn_log_group" {
  name = "/aws/step-functions/FetchRankStoresIngestion"
  retention_in_days = 14

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

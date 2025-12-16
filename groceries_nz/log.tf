resource "aws_cloudwatch_log_group" "single_store_ingestion_sfn_log_group" {
  name = "/aws/step-functions/SingleStoreIngestion"
  retention_in_days = 7

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_log_group" "fetch_rank_stores_ingestion_sfn_log_group" {
  name = "/aws/step-functions/FetchRankStoresIngestion"
  retention_in_days = 7

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_log_group" "level_1_store_dispatcher" {
  name = "/aws/lambda/${aws_lambda_function.level_1_store_dispatcher.function_name}"
  retention_in_days = 3

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_log_group" "level_2_category_dispatcher" {
  name = "/aws/lambda/${aws_lambda_function.level_2_category_dispatcher.function_name}"
  retention_in_days = 3

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_log_group" "level_3_paginator_dispatcher" {
  name = "/aws/lambda/${aws_lambda_function.level_3_paginator_dispatcher.function_name}"
  retention_in_days = 3

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_log_group" "level_4_item_indexer" {
  name = "/aws/lambda/${aws_lambda_function.level_4_item_indexer.function_name}"
  retention_in_days = 3

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_log_group" "level_5_item_aggregator" {
  name = "/aws/lambda/${aws_lambda_function.level_5_item_aggregator.function_name}"
  retention_in_days = 3

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_log_group" "level_6_item_copier" {
  name = "/aws/lambda/${aws_lambda_function.level_6_item_copier.function_name}"
  retention_in_days = 3

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_cloudwatch_log_group" "view_updater" {
  name = "/aws/lambda/${aws_lambda_function.view_updater.function_name}"
  retention_in_days = 3

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

locals {
  singe_store_ingestion_sfn_asl = templatefile("${path.module}/single_store_ingestion_sfn_definition.json", {
    s3_bucket_id = aws_s3_bucket.groceries-ingestion-data.id
    l2_lambda_arn  = aws_lambda_function.level_2_category_dispatcher.arn
    l3_lambda_arn  = aws_lambda_function.level_3_paginator_dispatcher.arn
    l4_lambda_arn  = aws_lambda_function.level_4_item_indexer.arn
    l5_lambda_arn = aws_lambda_function.level_5_item_aggregator.arn
    l6_lambda_arn = aws_lambda_function.level_6_item_copier.arn
  })
  fetch_rank_stores_ingestion_sfn_asl = templatefile("${path.module}/fetch_rank_stores_ingestion_sfn_definition.json", {
    single_store_ingestion_arn = aws_sfn_state_machine.single_store_ingestion.arn
    l1_lambda_arn  = aws_lambda_function.level_1_store_dispatcher.arn
    view_updater_arn = aws_lambda_function.view_updater.arn
  })
}

resource "aws_sfn_state_machine" "single_store_ingestion" {
  name       = "SingleStoreIngestion"
  role_arn   = aws_iam_role.single_store_ingestion_sfn_execution_role.arn
  definition = local.singe_store_ingestion_sfn_asl

  logging_configuration {
    log_destination = "${aws_cloudwatch_log_group.single_store_ingestion_sfn_log_group.arn}:*"
    include_execution_data = false
    level = "ALL"
  }

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}


resource "aws_sfn_state_machine" "fetch_rank_stores_ingestion" {
  name       = "FetchRankStoresIngestion"
  role_arn   = aws_iam_role.fetch_rank_stores_ingestion_sfn_execution_role.arn
  definition = local.fetch_rank_stores_ingestion_sfn_asl

  logging_configuration {
    log_destination = "${aws_cloudwatch_log_group.fetch_rank_stores_ingestion_sfn_log_group.arn}:*"
    include_execution_data = false
    level = "ALL"
  }

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

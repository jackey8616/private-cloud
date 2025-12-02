resource "aws_lambda_function" "level_2_category_dispatcher" {
  role = aws_iam_role.lambda-groceries-nz.arn
  image_uri = "${aws_ecr_repository.GroceriesNZ-Lambda.repository_url}@${var.ECR-Image-Sha}"
  package_type = "Image"
  function_name = "level_2_category_dispatcher"

  image_config {
    entry_point = []
    command = ["lambda_handlers.L2_category_dispatcher.handler"]
  }

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.groceries-ingestion-data.id
      DATABASE_URL = var.Lambda-PostgreSQL-Env
    }
  }

  timeout = 60

  layers = []

  architectures = ["x86_64"]

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group = "/aws/lambda/groceries-nz/level_2_category_dispatcher"
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_lambda_function" "level_3_paginator_dispatcher" {
  role = aws_iam_role.lambda-groceries-nz.arn
  image_uri = "${aws_ecr_repository.GroceriesNZ-Lambda.repository_url}@${var.ECR-Image-Sha}"
  package_type = "Image"
  function_name = "level_3_paginator_dispatcher"

  image_config {
    entry_point = []
    command = ["lambda_handlers.L3_paginator_dispatcher.handler"]
  }

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.groceries-ingestion-data.id
      DATABASE_URL = var.Lambda-PostgreSQL-Env
    }
  }

  timeout = 900

  layers = []

  architectures = ["x86_64"]

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group = "/aws/lambda/groceries-nz/level_3_paginator_dispatcher"
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_lambda_function" "level_4_item_indexer" {
  role = aws_iam_role.lambda-groceries-nz.arn
  image_uri = "${aws_ecr_repository.GroceriesNZ-Lambda.repository_url}@${var.ECR-Image-Sha}"
  package_type = "Image"
  function_name = "level_4_item_indexer"

  image_config {
    entry_point = []
    command = ["lambda_handlers.L4_item_indexer.handler"]
  }

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.groceries-ingestion-data.id
      DATABASE_URL = var.Lambda-PostgreSQL-Env
    }
  }

  timeout = 300

  layers = []

  architectures = ["x86_64"]

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group = "/aws/lambda/groceries-nz/level_4_item_indexer"
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_lambda_function" "level_5_item_aggregator" {
  role = aws_iam_role.lambda-groceries-nz.arn
  image_uri = "${aws_ecr_repository.GroceriesNZ-Lambda.repository_url}@${var.ECR-Image-Sha}"
  package_type = "Image"
  function_name = "level_5_item_aggregator"

  image_config {
    entry_point = []
    command = ["lambda_handlers.L5_item_aggregator.handler"]
  }

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.groceries-ingestion-data.id
      DATABASE_URL = var.Lambda-PostgreSQL-Env
    }
  }

  timeout = 900

  layers = []

  architectures = ["x86_64"]

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group = "/aws/lambda/groceries-nz/level_5_item_aggregator"
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}


resource "aws_lambda_function" "level_6_item_copier" {
  role = aws_iam_role.lambda-groceries-nz.arn
  image_uri = "${aws_ecr_repository.GroceriesNZ-Lambda.repository_url}@${var.ECR-Image-Sha}"
  package_type = "Image"
  function_name = "level_6_item_copier"

  image_config {
    entry_point = []
    command = ["lambda_handlers.L6_item_copier.handler"]
  }

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.groceries-ingestion-data.id
      DATABASE_URL = var.Lambda-PostgreSQL-Env
    }
  }

  timeout = 900

  layers = []

  architectures = ["x86_64"]

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group = "/aws/lambda/groceries-nz/level_6_item_copier"
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

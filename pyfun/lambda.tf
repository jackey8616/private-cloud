resource "aws_lambda_function" "stages_info_handler" {
  role          = aws_iam_role.lambda-pyfun.arn
  image_uri     = "${aws_ecr_repository.PyFun-Backend.repository_url}@${var.ECR-Image-Sha}"
  package_type  = "Image"
  function_name = "pyfun-stages_info_handler"

  image_config {
    entry_point = []
    command     = ["lambda_app.stages_info_handler"]
  }

  layers = []

  architectures = ["x86_64"]

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/pyfun-stages_info_handler"
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

resource "aws_lambda_permission" "stages_info_handler_apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.stages_info_handler.function_name
  source_arn    = "${aws_api_gateway_rest_api.PyFun.execution_arn}/*/*"
}

resource "aws_lambda_function" "stage_info_handler" {
  role          = aws_iam_role.lambda-pyfun.arn
  image_uri     = "${aws_ecr_repository.PyFun-Backend.repository_url}@${var.ECR-Image-Sha}"
  package_type  = "Image"
  function_name = "pyfun-stage_info_handler"

  image_config {
    entry_point = []
    command     = ["lambda_app.stage_info_handler"]
  }

  layers = []

  architectures = ["x86_64"]

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/pyfun-stage_info_handler"
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

resource "aws_lambda_permission" "stage_info_handler_apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.stage_info_handler.function_name
  source_arn    = "${aws_api_gateway_rest_api.PyFun.execution_arn}/*/*"
}

resource "aws_lambda_function" "lesson_verify_handler" {
  role          = aws_iam_role.lambda-pyfun.arn
  image_uri     = "${aws_ecr_repository.PyFun-Backend.repository_url}@${var.ECR-Image-Sha}"
  package_type  = "Image"
  function_name = "pyfun-lesson_verify_handler"

  image_config {
    entry_point = []
    command     = ["lambda_app.lesson_verify_handler"]
  }

  layers = []

  architectures = ["x86_64"]

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/pyfun-lesson_verify_handler"
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

resource "aws_lambda_permission" "lesson_verify_handler_apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.lesson_verify_handler.function_name
  source_arn    = "${aws_api_gateway_rest_api.PyFun.execution_arn}/*/*"
}

resource "aws_lambda_function" "lesson_info_handler" {
  role          = aws_iam_role.lambda-pyfun.arn
  image_uri     = "${aws_ecr_repository.PyFun-Backend.repository_url}@${var.ECR-Image-Sha}"
  package_type  = "Image"
  function_name = "pyfun-lesson_info_handler"

  image_config {
    entry_point = []
    command     = ["lambda_app.lesson_info_handler"]
  }

  layers = []

  architectures = ["x86_64"]

  ephemeral_storage {
    size = 512
  }

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/pyfun-lesson_info_handler"
  }

  tracing_config {
    mode = "PassThrough"
  }

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

resource "aws_lambda_permission" "lesson_info_handler_apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.lesson_info_handler.function_name
  source_arn    = "${aws_api_gateway_rest_api.PyFun.execution_arn}/*/*"
}

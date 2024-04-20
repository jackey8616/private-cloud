resource "aws_api_gateway_rest_api" "PyFun" {
  name = "pyfun"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

resource "aws_api_gateway_resource" "stages_info" {
  rest_api_id = aws_api_gateway_rest_api.PyFun.id
  parent_id   = aws_api_gateway_rest_api.PyFun.root_resource_id
  path_part   = "stage"
}

resource "aws_api_gateway_method" "stages_info_get" {
  rest_api_id   = aws_api_gateway_rest_api.PyFun.id
  resource_id   = aws_api_gateway_resource.stages_info.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "stages_info_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.PyFun.id
  resource_id             = aws_api_gateway_resource.stages_info.id
  http_method             = aws_api_gateway_method.stages_info_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.stages_info_handler.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_resource" "stage_info" {
  rest_api_id = aws_api_gateway_rest_api.PyFun.id
  parent_id   = aws_api_gateway_resource.stages_info.id
  path_part   = "{stage_name}"
}

resource "aws_api_gateway_method" "stage_info_get" {
  rest_api_id   = aws_api_gateway_rest_api.PyFun.id
  resource_id   = aws_api_gateway_resource.stage_info.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.stage_name" = true
  }
}

resource "aws_api_gateway_integration" "stage_info_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.PyFun.id
  resource_id             = aws_api_gateway_resource.stage_info.id
  http_method             = aws_api_gateway_method.stage_info_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.stage_info_handler.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_resource" "lesson_info" {
  rest_api_id = aws_api_gateway_rest_api.PyFun.id
  parent_id   = aws_api_gateway_resource.stage_info.id
  path_part   = "{lesson_name}"
}

resource "aws_api_gateway_method" "lesson_info_get" {
  rest_api_id   = aws_api_gateway_rest_api.PyFun.id
  resource_id   = aws_api_gateway_resource.lesson_info.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.stage_name"  = true
    "method.request.path.lesson_name" = true
  }
}

resource "aws_api_gateway_integration" "lesson_info_get_intergration" {
  rest_api_id             = aws_api_gateway_rest_api.PyFun.id
  resource_id             = aws_api_gateway_resource.lesson_info.id
  http_method             = aws_api_gateway_method.lesson_info_get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lesson_info_handler.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"

  cache_key_parameters = [
    "method.request.path.stage_name",
    "method.request.path.lesson_name",
  ]
}

resource "aws_api_gateway_method" "lesson_info_post" {
  rest_api_id   = aws_api_gateway_rest_api.PyFun.id
  resource_id   = aws_api_gateway_resource.lesson_info.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.stage_name"  = true
    "method.request.path.lesson_name" = true
  }
}

resource "aws_api_gateway_integration" "lesson_info_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.PyFun.id
  resource_id             = aws_api_gateway_resource.lesson_info.id
  http_method             = aws_api_gateway_method.lesson_info_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lesson_verify_handler.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "lesson_info_post_response" {
  rest_api_id = aws_api_gateway_rest_api.PyFun.id
  resource_id = aws_api_gateway_resource.lesson_info.id
  http_method = aws_api_gateway_method.lesson_info_post.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_method" "lesson_info_options" {
  rest_api_id   = aws_api_gateway_rest_api.PyFun.id
  resource_id   = aws_api_gateway_resource.lesson_info.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lesson_info_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.PyFun.id
  resource_id = aws_api_gateway_resource.lesson_info.id
  http_method = aws_api_gateway_method.lesson_info_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_method_response" "lesson_info_options_response" {
  rest_api_id = aws_api_gateway_rest_api.PyFun.id
  resource_id = aws_api_gateway_resource.lesson_info.id
  http_method = aws_api_gateway_method.lesson_info_options.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = false
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
  }
}

resource "aws_api_gateway_deployment" "v2_deployment" {
  rest_api_id = aws_api_gateway_rest_api.PyFun.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.PyFun.id))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "v2_stage" {
  stage_name    = "v2"
  rest_api_id   = aws_api_gateway_rest_api.PyFun.id
  deployment_id = aws_api_gateway_deployment.v2_deployment.id

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

resource "aws_api_gateway_domain_name" "pyfun-backend-v2_clo5de_info" {
  domain_name              = "pyfun-backend-v2.clo5de.info"
  regional_certificate_arn = aws_acm_certificate.pyfun-backend-v2_clo5de_info.arn

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

resource "aws_api_gateway_base_path_mapping" "pyfun-backend-v2_clo5de_info-path-mapping" {
  api_id      = aws_api_gateway_rest_api.PyFun.id
  domain_name = aws_api_gateway_domain_name.pyfun-backend-v2_clo5de_info.domain_name
  stage_name  = aws_api_gateway_stage.v2_stage.stage_name
}

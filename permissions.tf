resource "aws_iam_openid_connect_provider" "GitHub" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "1b511abead59c6ce207077c0bf0e0043b1382612"
  ]
}

data "aws_iam_policy_document" "AWSLambdaEdgeExecutionRole" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "AWSLambdaEdgeExecutionRole" {
  name   = "AWSLambdaEdgeExecutionRole-e4e39747-7cbe-4dfe-8650-487bfe11f3bf"
  path   = "/service-role/"
  policy = data.aws_iam_policy_document.AWSLambdaEdgeExecutionRole.json
}

data "aws_iam_policy_document" "ECR-Push-GroceriesNZ-Lambda" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
    ]

    resources = [
      aws_ecr_repository.GroceriesNZ-Lambda.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ECR-Push-GroceriesNZ-Lambda" {
  name = "ECR-Push-GroceriesNZ-Lambda"
  policy = data.aws_iam_policy_document.ECR-Push-GroceriesNZ-Lambda.json

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

data "aws_iam_policy_document" "lambda-groceries-nz-s3-policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.groceries-ingestion-data.id}/jobs/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.groceries-ingestion-data.id}/jobs/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = ["s3:ListBucket"]

    resources = ["arn:aws:s3:::${aws_s3_bucket.groceries-ingestion-data.id}"]
  }
}

resource "aws_iam_policy" "lambda-groceries-nz-s3-policy" {
  name        = "lambda-groceries-nz-s3-policy"
  policy      = data.aws_iam_policy_document.lambda-groceries-nz-s3-policy.json

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

data "aws_iam_policy_document" "lambda-groceries-nz" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda-groceries-nz" {
  name = "lambda-groceries-nz"
  path = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.lambda-groceries-nz.json
  managed_policy_arns = [
    var.Lambda-EdgeFunctionExecuteRole-Arn,
    aws_iam_policy.lambda-groceries-nz-s3-policy.arn,
  ]

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

data "aws_iam_policy_document" "Groceries-NZ-GH-Idp-Role" {
  statement {
    principals {
      type        = "Federated"
      identifiers = [var.GitHub-OIDC-Arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:jackey8616/Groceries-NZ:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "Groceries-NZ-GH-Idp-Role" {
  name               = "Groceries-NZ-GH-Idp-Role"
  description        = "GitHub Idp Role for push ECR images from Groceries-NZ repository."
  assume_role_policy = data.aws_iam_policy_document.Groceries-NZ-GH-Idp-Role.json

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

resource "aws_iam_role_policy_attachment" "Groceries-NZ-GH-ECR-Attachment" {
  role       = aws_iam_role.Groceries-NZ-GH-Idp-Role.name 
  
  policy_arn = aws_iam_policy.ECR-Push-GroceriesNZ-Lambda.arn
}

data "aws_iam_policy_document" "sfn_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn_execution_role" {
  name               = "sfn-groceries-nz-executor"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume_role.json

  tags = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.groceries_nz.application_tag)
}

data "aws_iam_policy_document" "sfn_policy" {
  statement {
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      aws_lambda_function.level_2_category_dispatcher.arn,
      aws_lambda_function.level_3_paginator_dispatcher.arn,
      aws_lambda_function.level_4_item_indexer.arn,
      aws_lambda_function.level_5_item_aggregator.arn,
      aws_lambda_function.level_6_item_copier.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = ["states:StartExecution"] 
    resources = [
      "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:${aws_sfn_state_machine.single_store_ingestion.name}",
    ]
  }

  statement {
    effect = "Allow"
    actions   = ["s3:GetObject", "s3:GetObjectAcl"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.groceries-ingestion-data.id}/*"]
  }

  statement {
    effect = "Allow"
    actions   = ["s3:PutObject", "s3:PutObjectAcl"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.groceries-ingestion-data.id}/sfn-output/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${aws_cloudwatch_log_group.sfn_log_group.arn}:*",
    ]
  }
}

resource "aws_iam_role_policy" "sfn_exec_policy" {
  name   = "sfn-groceries-nz-execution-policy"
  role   = aws_iam_role.sfn_execution_role.id
  policy = data.aws_iam_policy_document.sfn_policy.json
}

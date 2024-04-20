data "aws_iam_policy_document" "ECR-Push-PyFunBackend" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]

    resources = [
      aws_ecr_repository.PyFun-Backend.arn
    ]
  }

  statement {
    effect = "Allow"

    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ECR-Push-PyFunBackend" {
  name   = "ECR-Push-PyFunBackend"
  policy = data.aws_iam_policy_document.ECR-Push-PyFunBackend.json

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

data "aws_iam_policy_document" "PyFun-Backend-GH-Idp-Role" {
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
      values   = ["repo:jackey8616/PyFun-Backend:ref:refs/heads/master"]
    }
  }
}

resource "aws_iam_role" "PyFun-Backend-GH-Idp-Role" {
  name               = "PyFun-Backend-GH-Idp-Role"
  description        = "GitHub Idp Role for push ECR images from PyFun-Backend repository."
  assume_role_policy = data.aws_iam_policy_document.PyFun-Backend-GH-Idp-Role.json

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

data "aws_iam_policy_document" "lambda-pyfun" {
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

resource "aws_iam_role" "lambda-pyfun" {
  name               = "lambda-pyfun"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.lambda-pyfun.json
  managed_policy_arns = [
    var.Lambda-EdgeFunctionExecuteRole-Arn
  ]

  tags = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)

  tags_all = merge(aws_servicecatalogappregistry_application.pyfun.application_tag)
}

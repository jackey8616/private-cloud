module "PyFun" {
  source                             = "./pyfun"
  GitHub-OIDC-Arn                    = aws_iam_openid_connect_provider.GitHub.arn
  Lambda-EdgeFunctionExecuteRole-Arn = aws_iam_policy.AWSLambdaEdgeExecutionRole.arn
  ECR-Image-Sha                      = var.pyfun-aws-ecr-image-sha
  Cert_Key_Path                      = var.pyfun-aws-cert-key-path
  Cert_Pem_Path                      = var.pyfun-aws-cert-pem-path
}

module "Seeker" {
  source              = "./seeker"
  gcp-project-id      = var.seeker-gcp-project-id
  gcp-billing-account = var.seeker-gcp-billing-account
}

resource "aws_servicecatalogappregistry_application" "terraform" {
  name = "terraform"
}

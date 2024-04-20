module "PyFun" {
  source                             = "./pyfun"
  GitHub-OIDC-Arn                    = aws_iam_openid_connect_provider.GitHub.arn
  Lambda-EdgeFunctionExecuteRole-Arn = aws_iam_policy.AWSLambdaEdgeExecutionRole.arn
  ECR-Image-Sha                      = "sha256:3921acf6fb08f497d6eb521f047e4797b95783a143a74654bd63368dfc8a93f4"
  Cert_Key_Path                      = "pyfun/certs/pyfun-backend-v2.clo5de.info.key"
  Cert_Pem_Path                      = "pyfun/certs/pyfun-backend-v2.clo5de.info.pem"
}

resource "aws_servicecatalogappregistry_application" "terraform" {
  name = "terraform"
}

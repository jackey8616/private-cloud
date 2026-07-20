locals {
  github-org-name = "jackey8616"
}

module "GitHubOIDC" {
  source                = "./github-oidc"
  manage-gcp-project-id = local.silverfish["gcp-project-id"]
  github-org-name       = local.github-org-name
}

module "GitHub" {
  source                    = "./github"
  github-org-name           = local.github-org-name
  github-token              = local.github["token"]
  knight-strike-pages-cname = module.DNS.knight-strike-pages-fqdn
  repository-variables = {
    "Silverfish-Backend" = {
      GCP_PROJECT_ID                 = module.Silverfish.silverfish.backend.project_id
      GCP_REGION                     = module.Silverfish.silverfish.backend.region
      GCP_AR_REPOSITORY              = "silverfish-backend"
      GCP_CLOUD_RUN_SERVICE          = "silverfish-backend"
      GCP_WORKLOAD_IDENTITY_PROVIDER = module.GitHubOIDC.provider-name
      GCP_DEPLOY_SERVICE_ACCOUNT     = module.Silverfish.silverfish.oidc.gha_sa_email
    }
  }
}

module "DNS" {
  source                      = "./dns"
  cf-account-id               = local.cloudflare["account-id"]
  ip                          = module.ClodeClaw.clode-claw.instance.public_ipv4
  vpn-ip                      = module.Clode-Tools.clode-tools.vpn.ip
  vpn-jp-ip                   = module.Clode-Tools.clode-tools.vpn-jp.ip
  silverfish-backend-hostname = module.Silverfish.silverfish.backend.api_cname_target
}

module "Clode-Tools" {
  source              = "./clode-tools"
  gcp-project-id      = local.clode_tools["gcp-project-id"]
  gcp-billing-account = local.clode_tools["gcp-billing-account"]
  vpn-username        = local.clode_tools["vpn-username"]
  vpn-password        = local.clode_tools["vpn-password"]
  vpn-psk             = local.clode_tools["vpn-psk"]
  use-spot            = local.clode_tools["use-spot"]
}

module "PyFun" {
  source                             = "./pyfun"
  GitHub-OIDC-Arn                    = aws_iam_openid_connect_provider.GitHub.arn
  Lambda-EdgeFunctionExecuteRole-Arn = aws_iam_policy.AWSLambdaEdgeExecutionRole.arn
  ECR-Image-Sha                      = local.pyfun["aws-ecr-image-sha"]
  Cert_Arn                           = aws_acm_certificate_validation.pyfun_backend_v2.certificate_arn
}

module "Seeker" {
  source              = "./seeker"
  gcp-project-id      = local.seeker["gcp-project-id"]
  gcp-billing-account = local.seeker["gcp-billing-account"]
}

module "FomoBot" {
  source              = "./fomo-bot"
  gcp-project-id      = local.fomo_bot["gcp-project-id"]
  gcp-billing-account = local.fomo_bot["gcp-billing-account"]
}

module "Morpheus" {
  source              = "./morpheus"
  gcp-project-id      = local.morpheus["gcp-project-id"]
  gcp-billing-account = local.morpheus["gcp-billing-account"]
}

module "GroceriesNZ" {
  source                             = "./groceries_nz"
  GitHub-OIDC-Arn                    = aws_iam_openid_connect_provider.GitHub.arn
  Lambda-EdgeFunctionExecuteRole-Arn = aws_iam_policy.AWSLambdaEdgeExecutionRole.arn
  Lambda-PostgreSQL-Env              = local.groceries_nz["lambda-env-postgresql"]
  ECR-Image-Sha                      = local.groceries_nz["aws-ecr-image-sha"]
  providers = {
    aws = aws.sydney
  }
}

module "ClodeClaw" {
  source        = "./clode-claw"
  cf-account-id = local.cloudflare["account-id"]
  ssh_public_keys = [
    linode_sshkey.MacBookAir.ssh_key
  ]
  instance-env           = local.clode_claw["instance-env"]
  allowed_connection_ips = local.common["often-login-ips"]
  providers = {
    cloudflare = cloudflare
    linode     = linode
  }
}

module "Silverfish" {
  source       = "./silverfish"
  atlas-org-id = local.mongodbatlas["org-id"]
  # Atlas M0 doesn't support GCP private endpoints, and Cloud Run egress IPs
  # are dynamic. Open the IP allowlist; the database user password (managed in
  # Secret Manager) is the actual access control.
  allow-ips             = concat(local.common["often-login-ips"], ["0.0.0.0/0"])
  gcp-project-id        = local.silverfish["gcp-project-id"]
  gcp-billing-account   = local.silverfish["gcp-billing-account"]
  github-oidc-pool-name = module.GitHubOIDC.pool-name
  github-org-name       = local.github-org-name
}

resource "aws_servicecatalogappregistry_application" "terraform" {
  name = "terraform"
}

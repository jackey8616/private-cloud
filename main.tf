locals {
  github-org-name = "jackey8616"
}

module "GitHubOIDC" {
  source                = "./github-oidc"
  manage-gcp-project-id = var.silverfish.gcp-project-id
  github-org-name       = local.github-org-name
}

module "GitHub" {
  source          = "./github"
  github-org-name = local.github-org-name
  github-token    = var.terraform-management.github-token
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

import {
  to = module.GitHub.github_repository.silverfish-backend
  id = "Silverfish-Backend"
}

import {
  to = module.GitHub.github_repository.silverfish-vue
  id = "Silverfish-Vue"
}

module "DNS" {
  source        = "./dns"
  cf-account-id = var.terraform-management.cf-account-id
  ip            = module.ClodeClaw.clode-claw.instance.public_ipv4
  vpn-ip        = module.Clode-Tools.clode-tools.vpn.ip
}

module "Clode-Tools" {
  source              = "./clode-tools"
  gcp-project-id      = var.clode-tools.gcp-project-id
  gcp-billing-account = var.clode-tools.gcp-billing-account
  vpn-username        = var.clode-tools.vpn-username
  vpn-password        = var.clode-tools.vpn-password
  vpn-psk             = var.clode-tools.vpn-psk
  use-spot            = var.clode-tools.use-spot
}

module "PyFun" {
  source                             = "./pyfun"
  GitHub-OIDC-Arn                    = aws_iam_openid_connect_provider.GitHub.arn
  Lambda-EdgeFunctionExecuteRole-Arn = aws_iam_policy.AWSLambdaEdgeExecutionRole.arn
  ECR-Image-Sha                      = var.pyfun.aws-ecr-image-sha
  Cert_Key_Path                      = var.pyfun.aws-cert-key-path
  Cert_Pem_Path                      = var.pyfun.aws-cert-pem-path
}

module "Seeker" {
  source              = "./seeker"
  gcp-project-id      = var.seeker.gcp-project-id
  gcp-billing-account = var.seeker.gcp-billing-account
}

module "FomoBot" {
  source              = "./fomo-bot"
  gcp-project-id      = var.fomo-bot.gcp-project-id
  gcp-billing-account = var.fomo-bot.gcp-billing-account
}

module "Morpheus" {
  source              = "./morpheus"
  gcp-project-id      = var.morpheus.gcp-project-id
  gcp-billing-account = var.morpheus.gcp-billing-account
}

module "GroceriesNZ" {
  source                             = "./groceries_nz"
  GitHub-OIDC-Arn                    = aws_iam_openid_connect_provider.GitHub.arn
  Lambda-EdgeFunctionExecuteRole-Arn = aws_iam_policy.AWSLambdaEdgeExecutionRole.arn
  Lambda-PostgreSQL-Env              = var.groceries-nz.lambda-env-postgresql
  ECR-Image-Sha                      = var.groceries-nz.aws-ecr-image-sha
  providers = {
    aws = aws.sydney
  }
}

module "ClodeClaw" {
  source        = "./clode-claw"
  cf-account-id = var.terraform-management.cf-account-id
  ssh_public_keys = [
    linode_sshkey.MacBookAir.ssh_key
  ]
  instance-env           = var.clode-claw.instance-env
  allowed_connection_ips = var.terraform-management.often-login-ips
  providers = {
    cloudflare = cloudflare
    linode     = linode
  }
}

module "Silverfish" {
  source                = "./silverfish"
  atlas-org-id          = var.terraform-management.mongodbatlas-org-id
  allow-ips             = var.terraform-management.often-login-ips
  gcp-project-id        = var.silverfish.gcp-project-id
  gcp-billing-account   = var.silverfish.gcp-billing-account
  github-oidc-pool-name = module.GitHubOIDC.pool-name
  github-org-name       = local.github-org-name
}

import {
  to = module.Silverfish.google_project.silverfish
  id = var.silverfish.gcp-project-id
}

resource "aws_servicecatalogappregistry_application" "terraform" {
  name = "terraform"
}

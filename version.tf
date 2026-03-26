terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~>5"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.46.0"
    }

    linode = {
      source  = "linode/linode"
      version = "3.10.0"
    }
  }

  backend "s3" {
    encrypt                 = true
    bucket                  = "terraform-state20240420133633131400000001"
    key                     = "build-instance/terraform.tfstate"
    region                  = "ap-northeast-1"
    dynamodb_table          = "terraform_lock"
    shared_credentials_file = ".aws_credentials"
    profile                 = "default"
  }
}

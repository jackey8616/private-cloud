terraform {
  required_providers {
    aws = {
      source  = "aws"
      version = "5.46.0"
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


provider "cloudflare" {
  api_token = var.terraform-management.cf-token
}

provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = [".aws_credentials"]
  profile                  = "default"
}

provider "aws" {
  region                   = "ap-southeast-2"
  alias                    = "sydney"
  shared_credentials_files = [".aws_credentials"]
}

provider "linode" {
  token = var.terraform-management.linode-token
}

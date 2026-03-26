
provider "cloudflare" {
  api_token = var.cf-token
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
  token = var.linode-token
}

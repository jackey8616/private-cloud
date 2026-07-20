
provider "cloudflare" {
  api_token = local.cloudflare["token"]
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
  token = local.linode["token"]
}

provider "mongodbatlas" {
  public_key  = local.mongodbatlas["public-key"]
  private_key = local.mongodbatlas["private-key"]
}

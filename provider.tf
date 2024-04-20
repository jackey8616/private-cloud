provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = [".aws_credentials"]
  profile                  = "default"
}

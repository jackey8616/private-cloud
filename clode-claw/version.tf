terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "3.10.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~>5"
    }
  }
}

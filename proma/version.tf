terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "3.10.0"
    }

    github = {
      source  = "integrations/github"
      version = "6.12.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~>4"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3"
    }
  }
}

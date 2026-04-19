data "http" "init_script" {
  url = "https://raw.githubusercontent.com/jackey8616/my-claw/main/templates/init.sh.tpl"
}

locals {
  data = {
    r2_account_id        = var.cf-account-id,
    r2_access_key_id     = cloudflare_account_token.vps-token.id
    r2_secret_access_key = sha256(cloudflare_account_token.vps-token.value)
    r2_bucket_name       = cloudflare_r2_bucket.laura-vault.name
  }
}

resource "linode_instance" "openclaw_server" {
  label           = "openclaw"
  image           = "linode/ubuntu24.04"
  region          = linode_vpc.openclaw_sg_vpc.region
  type            = "g6-standard-1" # Linode SharedCPU 2GB RAM
  authorized_keys = var.ssh_public_keys
  root_pass       = var.instance_root_password

  metadata {
    user_data = base64encode(templatestring(
      data.http.init_script.response_body,
      merge(var.instance-env, local.data),
    ))
  }

  interface {
    purpose = "public"
  }

  interface {
    purpose   = "vpc"
    subnet_id = linode_vpc_subnet.openclaw_sg_default_subnet.id
    ipv4 {
      vpc = "10.0.1.10"
    }
  }
}

resource "linode_instance" "openclaw_server" {
  label           = "openclaw"
  image           = "linode/ubuntu24.04"
  region          = linode_vpc.openclaw_sg_vpc.region
  type            = "g6-standard-1" # Linode SharedCPU 2GB RAM
  authorized_keys = var.ssh_public_keys
  root_pass       = var.instance_root_password

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

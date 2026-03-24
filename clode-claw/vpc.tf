resource "linode_vpc" "openclaw_sg_vpc" {
  label       = "openclaw-sg-vpc"
  region      = "sg-sin-2"
  description = "VPC for OpenClaw Entry Agent in Singapore"
}

resource "linode_vpc_subnet" "openclaw_sg_default_subnet" {
  vpc_id = linode_vpc.openclaw_sg_vpc.id
  label  = "openclaw-sg-subnet"
  ipv4   = "10.0.1.0/24"
}

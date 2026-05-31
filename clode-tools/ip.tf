resource "google_compute_address" "ipsec" {
  name   = "ipsec-ip"
  region = var.region
}

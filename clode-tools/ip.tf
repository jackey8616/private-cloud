resource "google_compute_address" "ipsec" {
  name   = "ipsec-ip"
  region = var.region
}

resource "google_compute_address" "ipsec_jp" {
  name   = "ipsec-ip-jp"
  region = var.region-jp
}

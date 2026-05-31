resource "google_compute_firewall" "ipsec" {
  name    = "allow-ipsec"
  network = "default"

  allow {
    protocol = "udp"
    # ✅ 加入 1701 (L2TP)
    ports    = ["500", "1701", "4500"]
  }

  allow {
    protocol = "esp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ipsec-vpn"]
}

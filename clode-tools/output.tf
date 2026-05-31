output "clode-tools" {
  value = {
    vpn = {
      ip           = google_compute_address.ipsec.address
      check-status = "gcloud compute ssh ipsec-vpn-tw --zone=${var.zone} --project=${var.gcp-project-id} --command='docker ps && docker logs l2tp-ipsec-vpn'"
    }
  }
  sensitive = true
}

resource "google_compute_instance" "ipsec" {
  name         = "ipsec-vpn-tw"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["ipsec-vpn"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.ipsec.address
    }
  }

  metadata = {
    gce-container-declaration = yamlencode({
      spec = {
        containers = [{
          name  = "l2tp-ipsec-vpn"
          image = "hwdsl2/ipsec-vpn-server"
          env = [
            { name = "VPN_USER", value = var.vpn-username },
            { name = "VPN_PASSWORD", value = var.vpn-password },
            { name = "VPN_IPSEC_PSK", value = var.vpn-psk },
          ]
          securityContext = {
            privileged = true
          }
          volumeMounts = [{
            name      = "lib-modules"
            mountPath = "/lib/modules"
            readOnly  = true
          }]
        }]
        volumes = [{
          name     = "lib-modules"
          hostPath = { path = "/lib/modules" }
        }]
        restartPolicy = "Always"
      }
    })
  }

  scheduling {
    preemptible         = var.use-spot
    automatic_restart   = var.use-spot ? false : true
    on_host_maintenance = var.use-spot ? "TERMINATE" : "MIGRATE"
    provisioning_model  = var.use-spot ? "SPOT" : "STANDARD"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

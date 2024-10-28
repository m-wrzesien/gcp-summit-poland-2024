resource "google_compute_network" "main" {
  name                    = "gke"
  auto_create_subnetworks = false

  depends_on = [module.project-services]
}

resource "google_compute_subnetwork" "main" {
  name          = "gke"
  ip_cidr_range = "10.0.0.0/17"
  network       = google_compute_network.main.self_link

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "192.168.0.0/18"
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "192.168.64.0/18"
  }

  depends_on = [module.project-services]
}

# Allow access from Internet to k8s loadBalancers, as those are used for deployment of our frontend app
resource "google_compute_firewall" "allow-to-node-ports" {
  name      = "allow-to-gke-lb"
  network   = "default"
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags   = ["gke-${module.gke.name}"]
  source_ranges = ["0.0.0.0/0"]
}
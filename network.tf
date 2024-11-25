resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "my-subnetwork"
  region        = "us-central1-a"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.0.0/16"

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/20"
  }

  depends_on = [
    google_compute_network.vpc_network
  ]
}

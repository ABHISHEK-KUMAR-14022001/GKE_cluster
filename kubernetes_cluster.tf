resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count = 1

  network            = google_compute_network.vpc_network.name
  subnetwork         = google_compute_subnetwork.subnetwork.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  deletion_protection = false
}

resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  name       = var.node_pool_name
  node_count = var.node_pool_size

  node_config {
    preemptible  = false
    machine_type = "e2-medium"
    disk_size_gb = 10
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

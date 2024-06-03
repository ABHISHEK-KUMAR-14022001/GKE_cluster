terraform {
  backend "gcs" {
    bucket = "gcp-monitoring-425305"
    prefix = "terraform.tfstate"
  }
}

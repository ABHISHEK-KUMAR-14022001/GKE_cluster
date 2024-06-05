terraform {
  backend "gcs" {
    bucket = "monitoring-gcp-425505"
    prefix = "terraform.tfstate"
  }
}

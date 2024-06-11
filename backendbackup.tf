terraform {
  backend "gcs" {
    bucket = "gcp-cluster-426105"
    prefix = "terraform.tfstate"
  }
}

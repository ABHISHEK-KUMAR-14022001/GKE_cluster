terraform {
  backend "gcs" {
    bucket = "gcp-service-account-key"
    prefix = "terraform.tfstate"
  }
}

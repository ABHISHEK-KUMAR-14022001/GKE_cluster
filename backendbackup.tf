terraform {
  backend "gcs" {
    bucket = "gcp-test-425503"
    prefix = "terraform.tfstate"
  }
}

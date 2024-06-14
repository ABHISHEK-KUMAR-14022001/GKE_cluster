terraform {
  backend "gcs" {
    bucket = "devops-gcp-426408"
    prefix = "terraform.tfstate"
  }
}

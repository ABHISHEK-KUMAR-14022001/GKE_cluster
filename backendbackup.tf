terraform {
  backend "gcs" {
    bucket = "gcp-devops-426407"
    prefix = "terraform.tfstate"
  }
}

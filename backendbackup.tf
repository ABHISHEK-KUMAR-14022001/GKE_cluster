terraform {
  backend "gcs" {
    bucket = "devops-k8s-project"
    prefix = "terraform.tfstate"
  }
}

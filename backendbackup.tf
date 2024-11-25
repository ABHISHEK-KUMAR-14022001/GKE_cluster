terraform {
  backend "gcs" {
    bucket = "react-idp-app-backup"
    prefix = "terraform.tfstate"
  }
}

terraform {
  backend "gcs" {
    bucket = "devopsbackup2"
    prefix = "terraform.tfstate"
  }
}

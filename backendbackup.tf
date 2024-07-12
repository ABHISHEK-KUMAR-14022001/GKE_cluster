terraform {
  backend "gcs" {
    bucket = "gkestandardbucket"
    prefix = "terraform.tfstate"
  }
}

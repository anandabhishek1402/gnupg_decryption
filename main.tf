provider "google" {
  credentials = file("abhidhrk-ver-terraform.json")
  project     = "abhidhrk-ver"
}

terraform {
  backend "gcs" {
    bucket      = "cyb-ver-state"
    credentials = "abhidhrk-ver-terraform.json"
  }
}
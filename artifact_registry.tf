resource "google_artifact_registry_repository" "my-repo" {
  location      = "us-central1"
  repository_id = "my-ver-tf-repo"
  description   = "example docker repository"
  format        = "DOCKER"
}
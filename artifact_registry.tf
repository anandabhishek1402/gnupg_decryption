resource "google_artifact_registry_repository" "pact-etl-repo" {
  location      = "us-west2"
  repository_id = "pact-etl"
  description   = "Docker Repository"
  format        = "DOCKER"
  docker_config {
    immutable_tags = true
  }
}

# data "google_iam_policy" "admin" {
#   binding {
#     role = "roles/artifactregistry.reader"
#     members = [
#       "user:anand.abhishek78@gmail.com",
#     ]
#   }
#   binding {
#     role = "roles/artifactregistry.writer"
#     members = [
#       "user:anand.abhishek78@gmail.com",
#     ]
#   }
# }

# resource "google_artifact_registry_repository_iam_policy" "policy" {
#   project = google_artifact_registry_repository.pact-etl-repo.project
#   location = google_artifact_registry_repository.pact-etl-repo.location
#   repository = google_artifact_registry_repository.pact-etl-repo.name
#   policy_data = data.google_iam_policy.admin.policy_data
# }
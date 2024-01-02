# resource "google_secret_manager_secret" "secret-basic" {
#   count     = 2
#   secret_id = var.secrets[count.index]
#   project   = var.project_id

#   replication {
#     auto {
#       customer_managed_encryption {
#         kms_key_name = google_kms_crypto_key.tf-key.id
#       }
#     }
#   }
#   depends_on = [ google_project_service.project ]
# }
resource "google_secret_manager_secret" "secret-with-annotations" {
  count     = 2
  secret_id = var.secrets[count.index]
  project   = var.project_id
  replication {
    auto {}
  }
}
locals {
  kms_name = "keyring-ver"
  kms_location = "us"
  kms_crypto_name = "key"
}
resource "google_kms_key_ring" "keyring" {
  name       = local.kms_name
  location   = local.kms_location
  # depends_on = [google_project_service.project]
}


# data "google_iam_policy" "keyring" {
#   binding {
#     role = "roles/cloudkms.viewer"

#     members = [
#       "user:anand.abhishek1402@gmail.com",
#     ]
#   }
# }

# resource "google_kms_key_ring_iam_policy" "key_ring" {
#   key_ring_id = google_kms_key_ring.keyring.id
#   policy_data = data.google_iam_policy.keyring.policy_data
# }

resource "google_kms_crypto_key" "ver-key" {
  name     = local.kms_crypto_name
  key_ring = google_kms_key_ring.keyring.id
  #rotation_period = 0

  lifecycle {
    prevent_destroy = false
  }
  # depends_on = [google_project_service.project]
}

data "google_iam_policy" "decryptor" {
  binding {
    role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

    members = [
      "user:anand.abhishek1402@gmail.com",
    ]
  }
    binding {
      role = "roles/cloudkms.cryptoKeyDecrypter"

      members = [
        "user:anand.abhishek1402@gmail.com",
        "serviceAccount:${google_service_account.pact_etl_cloudrun_sa.email}",
      ]
    }
  # depends_on = [google_project_service.project]
}

resource "google_kms_crypto_key_iam_policy" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.ver-key.id
  policy_data = data.google_iam_policy.decryptor.policy_data
}


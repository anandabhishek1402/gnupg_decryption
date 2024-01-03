locals {
  secret_private_key_id = "privatekey"
  secret_passphrase_id = "passphrase"
}

resource "google_secret_manager_secret" "secret-private-key" {
  secret_id = local.secret_private_key_id
  project   = local.project
  replication {
    auto {}
  }
}

data "google_iam_policy" "secret-private-key" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:${google_service_account.pact_etl_cloudrun_sa.email}",
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "private-key-policy" {
  project = local.project
  secret_id = google_secret_manager_secret.secret-private-key.secret_id
  policy_data = data.google_iam_policy.secret-private-key.policy_data
}

resource "google_secret_manager_secret" "passphrase" {
  secret_id = local.secret_passphrase_id
  project   = local.project
  replication {
    auto {}
  }
}

data "google_iam_policy" "passphrase" {
  binding {
    role = "roles/secretmanager.secretAccessor"
    members = [
      "serviceAccount:${google_service_account.pact_etl_cloudrun_sa.email}",
    ]
  }
}

resource "google_secret_manager_secret_iam_policy" "passphrase-policy" {
  project = local.project
  secret_id = google_secret_manager_secret.passphrase.secret_id
  policy_data = data.google_iam_policy.passphrase.policy_data
}
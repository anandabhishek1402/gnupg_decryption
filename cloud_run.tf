locals {
    location = "us-west2"
    pact_etl_cloud_run_name = "pact-etl-cloud-run"
    pact_etl_cloud_run_sa = "pact-etl-cloud-run-sa"
    project = var.project_id
}

resource "google_service_account" "pact_etl_cloudrun_sa" {
    #Able to write files. KMS decrypt and secret accessor
  account_id   = local.pact_etl_cloud_run_sa
  display_name = local.pact_etl_cloud_run_sa
  description =  "Service Account for CLoud Run SA"
  project = local.project
}


resource "google_cloud_run_v2_service" "my_service" {
  name     = local.pact_etl_cloud_run_name
  location = local.location
  project = local.project
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

   template {
    scaling {
        max_instance_count = 1
        min_instance_count = 1
    }
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
        env {
        name = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name = "KMS_LOCATION"
        value = google_kms_key_ring.keyring.location
      }
      env {
        name = "KEY_RING"
        value = google_kms_key_ring.keyring.name
      }
      env {
        name = "CRYPTO_KEY"
        value = google_kms_crypto_key.ver-key.name
      }
      env {
        name = "GPG_SECRET_ID"
        value = google_secret_manager_secret.secret-private-key.secret_id
      }
      env {
        name = "DESTINTAION_BUCKET"
        value = google_storage_bucket.buckets-decrypted.name
      }
      env {
        name = "PASPPHRASE_SECRET_ID"
        value = google_secret_manager_secret.passphrase.secret_id
      }
    }
    service_account = google_service_account.pact_etl_cloudrun_sa.email
  }
}

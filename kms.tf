resource "google_kms_key_ring" "keyring" {
  name       = "tf-keyring4"
  location   = "global"
  depends_on = [google_project_service.project]
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/editor"

    members = [
      "user:anand.abhishek78@gmail.com",
      "serviceAccount:terraform@abhidhrk-ver.iam.gserviceaccount.com"
    ]
  }
  #   binding {
  #     role = "roles/cloudkms.keyRings.setIamPolicy"

  #     members = [
  #       "user:anand.abhishek78@gmail.com",
  #       "serviceAccount:terraform@abhidhrk-ver.iam.gserviceaccount.com"
  #     ]
  #   }
  binding {
    role = "roles/cloudkms.admin"

    members = [
      "user:anand.abhishek78@gmail.com",
      "serviceAccount:terraform@abhidhrk-ver.iam.gserviceaccount.com"
    ]
  }
  depends_on = [google_project_service.project]
}

resource "google_kms_key_ring_iam_policy" "key_ring" {
  key_ring_id = google_kms_key_ring.keyring.id
  policy_data = data.google_iam_policy.admin.policy_data
  depends_on  = [google_project_service.project]
}

resource "google_kms_crypto_key" "tf-key" {
  name     = "tfkey4"
  key_ring = google_kms_key_ring.keyring.id
  #rotation_period = 0

  lifecycle {
    prevent_destroy = false
  }
  depends_on = [google_project_service.project]
}
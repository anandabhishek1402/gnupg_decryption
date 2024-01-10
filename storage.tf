resource "google_storage_bucket" "buckets" {
  name          = "abhicyb-enc-ver"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

#   depends_on = [google_project_service.project]
}


data "google_iam_policy" "bucket_permissions" {
  binding {
    role = "roles/storage.admin"
    members = [
    #   "serviceAccount:${google_service_account.pact_etl_cloudrun_sa.email}",
      "user:anand.abhishek1402@gmail.com",
    ]
  }
  #   depends_on = [ google_project_service.project ]roles/storage.objectViewer
  binding {
    role = "roles/storage.objectViewer"
    members = [
    #   "serviceAccount:${google_service_account.pact_etl_cloudrun_sa.email}",
      "user:anand.abhishek1402@gmail.com",
      "serviceAccount:${google_service_account.pact_etl_cloudrun_sa.email}"
    ]
  }
}

resource "google_storage_bucket_iam_policy" "policy-enc" {
  bucket      = google_storage_bucket.buckets.name
  policy_data = data.google_iam_policy.bucket_permissions.policy_data
  #   depends_on = [ google_project_service.project ]
}

resource "google_storage_bucket" "buckets-decrypted" {
  name          = "abhicyb-dec-ver"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

#   depends_on = [google_project_service.project]
}

data "google_iam_policy" "bucket_dec_permissions" {
  binding {
    role = "roles/storage.objectCreator"
    members = [
      "serviceAccount:${google_service_account.pact_etl_cloudrun_sa.email}",
    ]
  }
    binding {
    role = "roles/storage.admin"
    members = [
    #   "serviceAccount:${google_service_account.pact_etl_cloudrun_sa.email}",
      "user:anand.abhishek1402@gmail.com",
    ]
  }
  #   depends_on = [ google_project_service.project ]
}
resource "google_storage_bucket_iam_policy" "policy-dec" {
  bucket      = google_storage_bucket.buckets.name
  policy_data = data.google_iam_policy.bucket_dec_permissions.policy_data
  #   depends_on = [ google_project_service.project ]
}
resource "google_storage_bucket_iam_policy" "policy-decrytpion" {
  bucket      = google_storage_bucket.buckets-decrypted.name
  policy_data = data.google_iam_policy.bucket_dec_permissions.policy_data
  #   depends_on = [ google_project_service.project ]
}
# resource "random_uuid" "rand" {}

resource "google_storage_bucket" "buckets" {
  for_each      = { for bucket in var.buckets : bucket => bucket }
  name          = each.key
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  depends_on = [google_project_service.project]
}

data "google_iam_policy" "bucket_permissions" {
  binding {
    role = "roles/storage.objectCreator"
    members = [
      "serviceAccount:${google_service_account.cloud_run_sa.email}",
      "user:anand.abhishek78@gmail.com",
      "serviceAccount:terraform@abhidhrk-ver.iam.gserviceaccount.com"
    ]
  }
  #   binding {
  #     role = "roles/storage.buckets.get"
  #     members = [
  #       "serviceAccount:${google_service_account.cloud_run_sa.email}",
  #       "user:anand.abhishek78@gmail.com",
  #       "serviceAccount:terraform@abhidhrk-ver.iam.gserviceaccount.com"
  #     ]
  #   }
  #   binding {
  #     role = "roles/storage.buckets.getIamPolicy"
  #     members = [
  #       "serviceAccount:${google_service_account.cloud_run_sa.email}",
  #       "user:anand.abhishek78@gmail.com",
  #       "serviceAccount:terraform@abhidhrk-ver.iam.gserviceaccount.com"
  #     ]
  #   }
  #   depends_on = [ google_project_service.project ]
}

resource "google_storage_bucket_iam_policy" "policy" {
  count       = 2
  bucket      = var.buckets[1]
  policy_data = data.google_iam_policy.bucket_permissions.policy_data
  #   depends_on = [ google_project_service.project ]
}
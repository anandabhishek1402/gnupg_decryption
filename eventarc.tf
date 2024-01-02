resource "google_service_account" "eventarc" {
  account_id   = "eventarc-trigger-sa"
  display_name = "Eventarc Trigger Service Account"
}

resource "google_project_iam_member" "eventreceiver" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}

resource "google_project_iam_member" "runinvoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.eventarc.email}"
}

# Grant the Cloud Storage service account permission to publish pub/sub topics
data "google_storage_project_service_account" "gcs_account" {}
resource "google_project_iam_member" "pubsubpublisher" {
  project = data.google_project.project.id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"
}



resource "google_eventarc_trigger" "primary" {
    name = "tf-eventarc"
    location = "us"
    matching_criteria {
        attribute = "type"
        value = "google.cloud.storage.object.v1.finalized"
    
    }
    matching_criteria {
    attribute = "bucket"  # Specify the bucket attribute
    value     = var.buckets[0]
  }

    destination {
        cloud_run_service {
            service = google_cloud_run_service.run.name
            region = "us-central1"
        }
    }
    service_account = google_service_account.eventarc.email

}



# Cloud Pub/Sub needs the role roles/iam.serviceAccountTokenCreator granted to service account 
# service-1074294592034@gcp-sa-pubsub.iam.gserviceaccount.com
#  on this project to create identity tokens. You can change this later.

# This trigger needs the role roles/eventarc.eventReceiver granted to service account 
# 1074294592034-compute@developer.gserviceaccount.com 
# to receive events via Google sources.

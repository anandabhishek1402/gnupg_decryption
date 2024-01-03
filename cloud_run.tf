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
    }
    service_account = google_service_account.pact_etl_cloudrun_sa.email
  }
}
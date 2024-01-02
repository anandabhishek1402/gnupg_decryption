resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-sa"
  display_name = "HRIS decryption sesrvice account"
  description  = "Seervice account for Cloud Run HRIS GPG Decryption"
  project      = var.project_id
  depends_on   = [google_project_service.project]
}
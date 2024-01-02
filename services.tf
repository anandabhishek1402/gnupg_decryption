resource "google_project_service" "project" {
  project                    = var.project_id
  for_each                   = { for api in var.enabled_apis : api => api }
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}
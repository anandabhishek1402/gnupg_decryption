/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "cloud_trigger_service_account" {
  value       = module.cloud_deploy_run.trigger_sa
  description = "List of Cloud Build Trigger Service Account"
}

output "cloud_deploy_service_account" {
  value       = module.cloud_deploy_run.execution_sa
  description = "List of Deploy target Execution Service Account"
}

output "delivery_pipeline_and_target" {
  value       = module.cloud_deploy_run.delivery_pipeline_and_target
  description = "List of Delivery Pipeline and respective Target"
}


output "cloud_run_services" {
  value = {
    name = google_cloud_run_service.run.name
    project = google_cloud_run_service.run.project
    location = google_cloud_run_service.run.location
  }
}
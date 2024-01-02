variable "project_id" {
  default = "abhidhrk-ver"
}

variable "enabled_apis" {
  description = "List of APIs to enable"
  type        = list(string)
  default = ["run.googleapis.com", "eventarc.googleapis.com", "artifactregistry.googleapis.com", "cloudkms.googleapis.com", "cloudresourcemanager.googleapis.com",
  "iam.googleapis.com", "secretmanager.googleapis.com","clouddeploy.googleapis.com"]
}

variable "buckets" {
  description = "List of buckets to create"
  type        = list(string)
  default     = ["gpg_encrypted_files_abhicyb", "gpg_decrypted_files_abhicyb"]
}

variable "secrets" {
  description = "List of secrets to create"
  type        = list(string)
  default     = ["privatekey", "passphrase"]
}

variable "stage_targets" {
  type = list(object({
    target_name        = string
    profiles           = list(string)
    target_create      = bool
    target_type        = string
    target_spec        = map(string)
    require_approval   = bool
    exe_config_sa_name = string
    execution_config   = map(string)
    strategy           = any
  }))
   default = [
    {
      target_name        = "default_target"
      profiles           = ["profile1", "profile2"]
      target_create      = true
      target_type        = "run"
      target_spec        = { project_id = "demo", location = "us-central1", run_service_sa="demo@gmail.com" }
      require_approval   = false
      exe_config_sa_name = "deployment-run-1-google"
      execution_config   = { config_key = "config_value" }
      strategy = {
      standard = { verify = true }
    }
    },
    # Add more default blocks if needed
  ]
}

variable "trigger_sa_name" {
  type = string
  default =""
}


variable "trigger_sa_create" {
  type = bool
  default = true
}
module "iam_bindings" {
    source = "terraform-google-modules/iam/google//modules/projects_iam"
    version = "~> 7.6"
    projects = [var.project_id]

bindings = {
    "roles/run.developer" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/iam.serviceAccountCreator" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/iam.serviceAccountUser" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/artifactregistry.writer" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/cloudkms.viewer" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/secretmanager.secretVersionManager" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/secretmanager.viewer" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/eventarc.developer" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/logging.viewer" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/monitoring.viewer" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/cloudbuild.builds.editor" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/serviceusage.serviceUsageConsumer" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/cloudkms.cryptoKeyEncrypterDecrypter" = [
        "user:anand.abhishek1402@gmail.com",
    ]
    "roles/storage.objectCreator" = [
        "user:anand.abhishek1402@gmail.com",
    ]



}

}
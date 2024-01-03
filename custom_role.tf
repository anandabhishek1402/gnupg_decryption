module "custom-roles" {
  source = "terraform-google-modules/iam/google//modules/custom_role_iam"

  target_level         = "project"
  target_id            = local.project
  role_id              = "list.buckets"
  title                = "Custom Role Unique Title"
  description          = "Custom Role Description"
#   base_roles           = ["roles/iam.serviceAccountAdmin"]
  permissions          = ["storage.buckets.list","storage.buckets.get","storage.buckets.getIamPolicy"]
#   excluded_permissions = ["iam.serviceAccounts.setIamPolicy"]
  members              = ["user:anand.abhishek1402@gmail.com"]
}
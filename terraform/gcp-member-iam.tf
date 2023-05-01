# declare resources for iam in member unit

resource "google_project_iam_member" "owner_member" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/owner",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.admin"
  ])
  role   = each.key
  member = "user:${var.owner_member_email}"
}

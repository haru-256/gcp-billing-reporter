resource "google_service_account" "tfc_service_account" {
  project      = var.gcp_project_id
  account_id   = "tfc-service-account"
  display_name = "Terraform Cloud Service Account"
}

resource "google_service_account_iam_member" "tfc_service_account_member" {
  service_account_id = google_service_account.tfc_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.tfc.name}/*"
}

resource "google_project_iam_member" "tfc_project_member" {
  project = var.gcp_project_id
  # TODO: change to minimum role
  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.tfc_service_account.email}"
}

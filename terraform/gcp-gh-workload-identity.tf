# declare resource for connectiong between Github Action and GCP

# github action service account
resource "google_service_account" "gh" {
  project      = var.gcp_project_id
  account_id   = "github-action"
  display_name = "Github Action Service Account"
}
resource "google_project_iam_member" "gh_project_member" {
  project = var.gcp_project_id
  # TODO: change to minimum role
  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.gh.email}"
}

# build workload identity for github actions
# tflint-ignore: terraform_module_version
module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = var.gcp_project_id
  pool_id     = "github-action"
  provider_id = "githu-action"
  sa_mapping = {
    (google_service_account.gh.account_id) = {
      sa_name   = google_service_account.gh.name
      attribute = "attribute.repository/haru-256/gcp-billing-reporter"
    }
  }
}


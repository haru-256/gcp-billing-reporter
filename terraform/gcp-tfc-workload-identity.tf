# declare resource for connectiong between Terraform Cloud and GCP

data "google_project" "project" {
  project_id = var.gcp_project_id
}

# GCP workload identity
resource "google_iam_workload_identity_pool" "tfc" {
  project                   = var.gcp_project_id
  provider                  = google-beta
  workload_identity_pool_id = "terraform-cloud"
}
resource "google_iam_workload_identity_pool_provider" "tfc" {
  project                            = var.gcp_project_id
  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.tfc.workload_identity_pool_id
  workload_identity_pool_provider_id = "terraform-cloud"
  attribute_mapping = {
    "google.subject"                        = "assertion.sub",
    "attribute.aud"                         = "assertion.aud",
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase",
    "attribute.terraform_project_id"        = "assertion.terraform_project_id",
    "attribute.terraform_project_name"      = "assertion.terraform_project_name",
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id",
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name",
    "attribute.terraform_run_id"            = "assertion.terraform_run_id",
    "attribute.terraform_full_workspace"    = "assertion.terraform_full_workspace",
  }
  oidc {
    issuer_uri = "https://app.terraform.io"
  }
  attribute_condition = "assertion.sub.startsWith(\"organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}\")"
}
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
  for_each = toset([
    "roles/editor",
    "roles/resourcemanager.projectIamAdmin",
    "roles/secretmanager.admin"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.tfc_service_account.email}"
}

# terraform cloud variables for connectiong to bigquery
resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = tfe_workspace.workspace.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for GCP."
}
resource "tfe_variable" "tfc_gcp_project_number" {
  workspace_id = tfe_workspace.workspace.id

  key      = "TFC_GCP_PROJECT_NUMBER"
  value    = data.google_project.project.number
  category = "env"

  description = "The numeric identifier of the GCP project"
}
resource "tfe_variable" "tfc_gcp_workload_pool_id" {
  workspace_id = tfe_workspace.workspace.id

  key      = "TFC_GCP_WORKLOAD_POOL_ID"
  value    = google_iam_workload_identity_pool.tfc.workload_identity_pool_id
  category = "env"

  description = "The ID of the workload identity pool."
}
resource "tfe_variable" "tfc_gcp_workload_provider_id" {
  workspace_id = tfe_workspace.workspace.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_ID"
  value    = google_iam_workload_identity_pool_provider.tfc.workload_identity_pool_provider_id
  category = "env"

  description = "The ID of the workload identity pool provider."
}
resource "tfe_variable" "tfc_gcp_service_account_email" {
  workspace_id = tfe_workspace.workspace.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = google_service_account.tfc_service_account.email
  category = "env"

  description = "The GCP service account email runs will use to authenticate."
}

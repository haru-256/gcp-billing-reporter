# declare resource for terrafrom cloud workspace
resource "tfe_project" "project" {
  organization = var.tfc_organization_name
  name         = var.tfc_project_name
}

resource "tfe_workspace" "workspace" {
  name                = var.tfc_workspace_name
  organization        = var.tfc_organization_name
  project_id          = tfe_project.project.id
  speculative_enabled = true
  # auto_apply          = false
  # working_directory   = "terraform/"
  # vcs_repo {
  #   github_app_installation_id = var.tfc_vcs_repo_ghain
  #   identifier                 = var.tfc_vcs_repo_identifier
  #   ingress_submodules         = false
  #   branch                     = "main"
  # }
}

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

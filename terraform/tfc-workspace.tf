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
  auto_apply          = false
  working_directory   = "terraform"
  vcs_repo {
    github_app_installation_id = var.tfc_vcs_repo_ghain
    identifier                 = var.tfc_vcs_repo_identifier
    ingress_submodules         = false
    branch                     = "main"
  }
}

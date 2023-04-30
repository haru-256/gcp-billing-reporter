data "github_repository" "gcp_billing_reporter" {
  full_name = "haru-256/gcp-billing-reporter"
}

resource "github_actions_variable" "gcp_project_id" {
  repository    = data.github_repository.gcp_billing_reporter.name
  variable_name = "GCP_PROJECT_ID"
  value         = "haru256-billing-report"
}

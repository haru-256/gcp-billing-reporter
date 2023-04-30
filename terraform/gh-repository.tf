data "github_repository" "gcp_billing_reporter" {
  full_name = "haru-256/gcp-billing-reporter"
}

resource "github_actions_variable" "gcp_project_id" {
  repository    = data.github_repository.gcp_billing_reporter.name
  variable_name = "GCP_PROJECT_ID"
  value         = var.gcp_project_id
}

resource "github_actions_variable" "gh_gcp_workload_identity_provider" {
  repository    = data.github_repository.gcp_billing_reporter.name
  variable_name = "GH_GCP_WORKLOAD_IDENTITY_PROVIDER"
  value         = module.gh_oidc.provider_name
}

resource "github_actions_variable" "gh_gcp_service_account" {
  repository    = data.github_repository.gcp_billing_reporter.name
  variable_name = "GH_GCP_SERVICE_ACCOUNT"
  value         = google_service_account.gh.email
}

resource "github_actions_variable" "billing_reporter_gcp_service_account" {
  repository    = data.github_repository.gcp_billing_reporter.name
  variable_name = "BILLING_REPORTER_GCP_SERVICE_ACCOUNT"
  value         = google_service_account.billing_reporter.email
}

resource "github_actions_variable" "billing_reporter_pubsub_topic" {
  repository    = data.github_repository.gcp_billing_reporter.name
  variable_name = "BILLING_REPORTER_PUBSUB_TOPIC"
  value         = google_pubsub_topic.billing_reporter.id
}

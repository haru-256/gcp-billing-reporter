output "gh_workload_identity_provider" {
  description = "The name of GCP Workload Identity Provider for Github Action"
  value       = module.gh_oidc.provider_name
}

output "gh_sa_email" {
  description = "The emai of GCP Service Account for Github Action"
  value       = google_service_account.gh.email
}

output "billing_reporter_sa_email" {
  description = "The emai of GCP Service Account for Billing Reporter"
  value       = google_service_account.billing_reporter.email
}

output "billing_reporter_pubsub_topic" {
  description = "The name of GCP PubSub Topic for Billing Reporter"
  value       = google_service_account.billing_reporter.email
}

# declare resources for billing reporter

# bigquery dataset that GCP export billing data to
resource "google_bigquery_dataset" "all_billing_data" {
  location                   = var.gcp_default_region
  project                    = var.gcp_project_id
  dataset_id                 = "all_billing_data"
  description                = "Storing billing data for all google cloud project"
  delete_contents_on_destroy = "false"

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
  access {
    role          = "OWNER"
    user_by_email = "billing-export-bigquery@system.gserviceaccount.com"
  }

}

# pubsub that cloud scheduler push to
resource "google_pubsub_topic" "billing_reporter" {
  name = "billing_reporter"
}

# to store cloud function logs
resource "google_storage_bucket" "billing_reporter_cloud_function_logs" {
  name                        = "${var.gcp_project_id}-billing-reporter-cloud-function-logs"
  location                    = var.gcp_default_region
  uniform_bucket_level_access = true
}

# run scheduler job of billing report
resource "google_cloud_scheduler_job" "billing_reporter" {
  description = "Billing report to slack"
  name        = "billing-reporter"

  pubsub_target {
    data       = base64encode("billing-reporter")
    topic_name = google_pubsub_topic.billing_reporter.id
  }

  retry_config {
    max_backoff_duration = "3600s"
    max_doublings        = "5"
    max_retry_duration   = "0s"
    min_backoff_duration = "5s"
    retry_count          = "0"
  }

  schedule  = "0 5 * * *"
  time_zone = "Asia/Tokyo"
}

# Use this secret in cloud run endpoint
resource "google_secret_manager_secret" "slack_webhook_url" {
  secret_id = "SLACK_WEBHOOK_URL"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "slack_webhook_url" {
  secret = google_secret_manager_secret.slack_webhook_url.id

  secret_data = var.gcp_billing_reporter_slack_webhook_url
}

# billing reporter service account
resource "google_service_account" "billing_reporter" {
  project      = var.gcp_project_id
  account_id   = "billing-reporter"
  display_name = "Billing Reporter Service Account"
  description  = "Billing Report Service Account."
}
resource "google_project_iam_member" "billing_report" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/bigquery.dataViewer",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/bigquery.readSessionUser",
    "roles/cloudbuild.builds.builder",
    "roles/cloudfunctions.developer",
    "roles/logging.logWriter",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.admin"
  ])
  role   = each.key
  member = "serviceAccount:${google_service_account.billing_reporter.email}"
}

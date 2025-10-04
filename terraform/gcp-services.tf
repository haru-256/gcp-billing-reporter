# declare resource for gcp services

locals {
  gcp_services = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "eventarc.googleapis.com"
  ])
}

resource "google_project_service" "services" {
  project  = var.gcp_project_id
  for_each = local.gcp_services
  service  = each.key
}

# declare resource for gcp services

locals {
  gcp_services = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

resource "google_project_service" "services" {
  project = var.gcp_project_id
  count   = length(local.gcp_services)
  service = local.gcp_services[count.index]
}

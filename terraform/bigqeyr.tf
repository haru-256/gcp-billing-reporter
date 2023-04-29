# declare bigquery dataset

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

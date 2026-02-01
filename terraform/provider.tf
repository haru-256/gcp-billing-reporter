terraform {
  required_version = "~>1.13.3"
  cloud {
    organization = "haru256"
    hostname     = "app.terraform.io"
    workspaces {
      name = "haru256-billing-report"
    }
  }
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.70.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>7.17.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~>7.9.0"
    }
    github = {
      source  = "integrations/github"
      version = "~>6.7.5"
    }
  }
}

provider "tfe" {
  hostname = "app.terraform.io"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_default_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_default_region
}

provider "github" {}

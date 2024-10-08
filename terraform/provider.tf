terraform {
  required_version = "~>1.4.6"
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
      version = "~> 0.57.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>5.27.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~>5.39.1"
    }
    github = {
      source  = "integrations/github"
      version = "~>6.2.1"
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

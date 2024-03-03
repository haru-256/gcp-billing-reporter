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
      version = "~> 0.52.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>4.63.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~>4.63.1"
    }
    github = {
      source  = "integrations/github"
      version = "~>5.23.0"
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

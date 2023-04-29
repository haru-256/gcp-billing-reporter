variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  description = "The project under which a workspace will be created"
}

variable "tfc_workspace_name" {
  type        = string
  description = "The name of the workspace that you'd like to create and connect to GCP"
}

variable "tfc_vcs_repo_ghain" {
  type        = string
  description = "github app installation id"
}

variable "tfc_vcs_repo_identifier" {
  type        = string
  description = "vcs identifier"
}

variable "gcp_project_id" {
  type        = string
  description = "The ID for your GCP project"
}

variable "gcp_default_region" {
  type        = string
  description = "The name for your GCP default region"
}

# declare resources for iam in member unit

resource "google_project_iam_member" "owner_member" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/owner",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.admin"
  ])
  role   = each.key
  member = "user:${var.owner_member_email}"
}

# Cloud Functions Service Agent に必要なロールを付与
resource "google_project_iam_member" "cloud_function_service_agent" {
  project = var.gcp_project_id
  for_each = toset([
    "roles/cloudfunctions.serviceAgent",       # Cloud Functions の実行に必須
    "roles/iam.serviceAccountUser",            # ランタイム用 SA の利用権限
    "roles/iam.serviceAccountTokenCreator",    # OIDC 等のトークン作成で必要になることがある
    "roles/storage.objectAdmin",               # gcf-v2-uploads バケットへの書き込み権限
    "roles/storage.legacyBucketReader"         # バケットのメタデータ参照
  ])
  role   = each.key
  member = "serviceAccount:${var.gcp_cloud_function_service_agent}"
}

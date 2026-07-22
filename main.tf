locals {
  # By default the read-only permissions Fencer's configuration scanning requires, generated from
  # Fencer's single source of truth (do not edit role_permissions.txt by hand). Supply
  # override_permissions to replace the list wholesale with permissions you control.
  scanner_permissions = var.override_permissions != null ? var.override_permissions : split("\n", trimspace(file("${path.module}/role_permissions.txt")))

  required_apis = var.enable_apis ? toset(concat(
    [
      "iam.googleapis.com",
      "cloudasset.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "serviceusage.googleapis.com",
    ],
    var.enable_access_context_manager ? ["accesscontextmanager.googleapis.com"] : [],
  )) : toset([])
}

resource "google_project_service" "required" {
  for_each = local.required_apis
  project  = var.project_id
  service  = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_iam_custom_role" "fencer_scanner" {
  project     = var.project_id
  role_id     = var.custom_role_id
  title       = "FencerScannerRole"
  description = "Custom role for Fencer Scanner with minimum required permissions"
  permissions = local.scanner_permissions
}

resource "google_service_account" "fencer_scanner" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Fencer Scanner"
}

resource "google_project_iam_member" "fencer_scanner" {
  project = var.project_id
  role    = google_project_iam_custom_role.fencer_scanner.id
  member  = "serviceAccount:${google_service_account.fencer_scanner.email}"
}

resource "google_service_account_key" "fencer_scanner" {
  count              = var.create_key ? 1 : 0
  service_account_id = google_service_account.fencer_scanner.name
}

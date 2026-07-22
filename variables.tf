variable "project_id" {
  type        = string
  description = "ID of the GCP project to grant Fencer configuration scanning access to."
}

variable "service_account_id" {
  type        = string
  description = "Account ID (local part) of the service account Fencer will authenticate as."
  default     = "fencer-scanner"
}

variable "custom_role_id" {
  type        = string
  description = "ID of the custom project role holding Fencer's read-only permissions."
  default     = "FencerScannerRole"
}

variable "override_permissions" {
  type        = list(string)
  description = "Replace Fencer's default custom-role permission list entirely with this list. Leave null to use the default. When set, you own keeping it aligned with what Fencer needs — reducing it may cause scan gaps."
  default     = null
}

variable "enable_apis" {
  type        = bool
  description = "Enable the Google APIs the scanner requires on the project. Set to false if you manage API enablement elsewhere."
  default     = true
}

variable "enable_access_context_manager" {
  type        = bool
  description = "Also enable the Access Context Manager API (required for Context-Aware Access scanning)."
  default     = false
}

variable "create_key" {
  type        = bool
  description = "Create a service-account JSON key to upload into Fencer. Disable if you provision the key out of band."
  default     = true
}

output "service_account_email" {
  description = "Email of the created service account."
  value       = google_service_account.fencer_scanner.email
}

output "service_account_key" {
  description = "Base64-encoded service-account JSON key. Decode it (`terraform output -raw service_account_key | base64 --decode`) and upload the JSON into Fencer."
  value       = var.create_key ? google_service_account_key.fencer_scanner[0].private_key : null
  sensitive   = true
}

output "project_id" {
  description = "The project the scanner service account was created in."
  value       = var.project_id
}

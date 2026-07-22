terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = "my-project-id"
}

module "fencer_scanner" {
  source = "../../"

  project_id = "my-project-id"
}

output "service_account_email" {
  value = module.fencer_scanner.service_account_email
}

# Decode with: terraform output -raw service_account_key | base64 --decode > fencer-scanner-key.json
output "service_account_key" {
  value     = module.fencer_scanner.service_account_key
  sensitive = true
}

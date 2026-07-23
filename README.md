## terraform-google-fencer-scanner

Terraform module that provisions the least-privilege, read-only GCP access [Fencer](https://www.fencer.dev)'s
configuration scanning requires. It enables the required APIs, creates a custom project role with the
read-only permissions Fencer needs, creates a `fencer-scanner` service account bound to that role, and
(by default) generates a JSON key to upload into Fencer.

This is the Infrastructure-as-Code equivalent of the manual console steps shown in the Fencer GCP
connection wizard — apply it instead of clicking through them.

### Usage

```hcl
module "fencer_scanner" {
  source  = "Fencer-Security/fencer-scanner/google"
  version = "~> 1.0"

  project_id = "my-project-id"
}

# Decode and upload the JSON key into Fencer:
#   terraform output -raw service_account_key | base64 --decode > fencer-scanner-key.json
output "service_account_key" {
  value     = module.fencer_scanner.service_account_key
  sensitive = true
}
```

After `terraform apply`, upload the decoded JSON key into the GCP connection form in Fencer.

### Use from Pulumi

Pulumi consumes this module directly — no rewrite. Add it to your project, then instantiate the generated
`Module` component (works in TypeScript, Python, Go, or YAML):

```bash
pulumi package add terraform-module Fencer-Security/fencer-scanner/google 1.0.0 fencerscanner
```

```ts
import * as fencerscanner from "@pulumi/fencerscanner";

const scanner = new fencerscanner.Module("fencer-scanner", {
  project_id: "my-project-id",
});

export const serviceAccountKey = scanner.service_account_key;
```

Inputs and outputs mirror the module's variables/outputs documented below.

### What gets created

- The Google APIs the scanner needs, enabled on the project (`iam`, `cloudasset`, `cloudresourcemanager`,
  `serviceusage`; optionally `accesscontextmanager`).
- A custom project role (`FencerScannerRole`) with the read-only permissions Fencer needs (the exact list
  lives in [`role_permissions.txt`](./role_permissions.txt)).
- A `fencer-scanner` service account, bound to the custom role.
- A service-account JSON key (unless `create_key = false`).

`role_permissions.txt` is generated from Fencer's single source of truth; the console instructions, this
module, and the CLI setup script all derive from it, so they never drift apart. Do not edit it by hand.

Container/registry scanning (Artifact Registry, GKE) needs no extra configuration — those permissions are
already part of the base role.

> **Security note:** enabling `create_key` writes the service-account private key into Terraform state.
> Use a secured, encrypted remote backend and treat the state as sensitive. To manage the key out of band,
> set `create_key = false`.

### Custom permissions

By default the custom role uses Fencer's permission list (`role_permissions.txt`). To control exactly what
Fencer can read — for example, to keep it out of your registries and GKE clusters — supply
`override_permissions` to replace the list wholesale. It's all-or-nothing: either the default, or a list
you own. Because this module grants **only** the custom role (no `roles/viewer`), the list is authoritative.

```hcl
module "fencer_scanner" {
  source  = "Fencer-Security/fencer-scanner/google"
  version = "~> 1.0"

  project_id = "my-project-id"

  # Start from role_permissions.txt, drop what you don't want, pass the result here.
  override_permissions = split("\n", trimspace(file("${path.module}/my-fencer-permissions.txt")))
}
```

> **Note:** when you override, you own keeping the list aligned with what Fencer needs — removing
> permissions may cause scan gaps.

### Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | :---: |
| `project_id` | GCP project to grant scanning access to. | `string` | n/a | yes |
| `service_account_id` | Account ID of the service account Fencer authenticates as. | `string` | `"fencer-scanner"` | no |
| `custom_role_id` | ID of the custom project role. | `string` | `"FencerScannerRole"` | no |
| `override_permissions` | Full permission list to use instead of Fencer's default custom-role list. | `list(string)` | `null` | no |
| `enable_apis` | Enable the required Google APIs on the project. | `bool` | `true` | no |
| `enable_access_context_manager` | Also enable the Access Context Manager API. | `bool` | `false` | no |
| `create_key` | Create a service-account JSON key to upload into Fencer. | `bool` | `true` | no |

### Outputs

| Name | Description |
| --- | --- |
| `service_account_email` | Email of the created service account. |
| `service_account_key` | Base64-encoded JSON key (sensitive) — decode and upload into Fencer. |
| `project_id` | The project the service account was created in. |

### Requirements

- Terraform `>= 1.5`
- Google provider `>= 5.0`

### License

[MIT](./LICENSE)

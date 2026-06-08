# res-azure-webapp

Generic, organization-wide resource module that provisions an Azure
Linux Web App for Containers together with its App Service Plan.
Defaults to hosting [Open WebUI](https://github.com/open-webui/open-webui)
(`ghcr.io/open-webui/open-webui:main`) but any container image and
registry can be supplied. Optional private endpoint and Log Analytics
diagnostic setting are included.

## Usage

```hcl
module "webapp" {
  source  = "git::https://github.com/noplacelikecloud/res-azure-webapp.git?ref=v1.0.0"

  name                = "app-chatbot-prod"
  resource_group_name = "rg-chatbot-prod"
  location            = "westeurope"

  service_plan = {
    sku_name = "P1v3"
  }

  app_settings = {
    OPENAI_API_BASE_URL = "https://my-foundry.cognitiveservices.azure.com/openai/deployments/gpt-4o-mini"
    OPENAI_API_KEY      = "@Microsoft.KeyVault(SecretUri=https://kv.vault.azure.net/secrets/foundry-key/)"
    WEBUI_AUTH          = "False"
  }

  diagnostic_log_analytics_workspace_id = module.law.id
}
```

## Inputs

| Name                                  | Type                                                                       | Default                                | Description                                                |
| ------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------- | ---------------------------------------------------------- |
| name                                  | string                                                                     | n/a                                    | Web App name (2-60 chars).                                 |
| resource_group_name                   | string                                                                     | n/a                                    | Hosting resource group.                                    |
| location                              | string                                                                     | n/a                                    | Azure region.                                              |
| service_plan                          | object({name?, sku_name?})                                                 | `{sku_name = "B1"}`                    | App Service Plan settings. OS is forced to Linux.          |
| container                             | object({image?, registry_url?})                                            | Open WebUI on GHCR                     | Container image and registry.                              |
| app_settings                          | map(string)                                                                | `{}`                                   | Environment variables.                                     |
| https_only                            | bool                                                                       | `true`                                 | Force HTTPS-only traffic.                                  |
| identity_type                         | string                                                                     | `SystemAssigned`                       | Managed identity type.                                     |
| user_assigned_identity_ids            | list(string)                                                               | `[]`                                   | User-assigned identity IDs.                                |
| public_network_access_enabled         | bool                                                                       | `true`                                 | Public network access.                                     |
| private_endpoint                      | object({name?, subnet_id, private_dns_zone_ids?}) or null                  | `null`                                 | Optional private endpoint.                                 |
| diagnostic_log_analytics_workspace_id | string or null                                                             | `null`                                 | When set, creates a diagnostic setting to that workspace.  |
| tags                                  | map(string)                                                                | `{}`                                   | Tags.                                                      |

## Outputs

| Name                | Description                                                            |
| ------------------- | ---------------------------------------------------------------------- |
| id                  | Web App resource ID.                                                   |
| name                | Web App name.                                                          |
| default_hostname    | Default hostname (`<name>.azurewebsites.net`).                         |
| principal_id        | System-Assigned MI principal ID, or null when not enabled.             |
| service_plan_id     | App Service Plan resource ID.                                          |
| private_endpoint_id | Private endpoint ID, or null when not created.                         |

## Tests

```bash
terraform init -backend=false
terraform test
```

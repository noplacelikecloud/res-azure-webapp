mock_provider "azurerm" {}

variables {
  name                = "app-unit-test"
  resource_group_name = "rg-unit-test"
  location            = "westeurope"
}

run "plan_defaults" {
  command = plan

  assert {
    condition     = azurerm_service_plan.this.os_type == "Linux"
    error_message = "Service plan OS must be Linux."
  }

  assert {
    condition     = azurerm_service_plan.this.sku_name == "B1"
    error_message = "Default service plan SKU should be B1."
  }

  assert {
    condition     = azurerm_service_plan.this.name == "app-unit-test-plan"
    error_message = "Default service plan name should be '<webapp>-plan'."
  }

  assert {
    condition     = azurerm_linux_web_app.this.https_only == true
    error_message = "https_only should default to true."
  }

  assert {
    condition     = azurerm_linux_web_app.this.site_config[0].application_stack[0].docker_image_name == "ghcr.io/open-webui/open-webui:main"
    error_message = "Default container image should be Open WebUI on GHCR."
  }

  assert {
    condition     = azurerm_linux_web_app.this.identity[0].type == "SystemAssigned"
    error_message = "Default identity should be SystemAssigned."
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 0
    error_message = "No private endpoint should be created by default."
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 0
    error_message = "No diagnostic setting should be created by default."
  }
}

run "plan_with_kv_app_settings" {
  command = plan

  variables {
    name                = "app-kvref"
    resource_group_name = "rg-unit-test"
    location            = "westeurope"
    app_settings = {
      OPENAI_API_KEY      = "@Microsoft.KeyVault(SecretUri=https://kv.vault.azure.net/secrets/key/)"
      OPENAI_API_BASE_URL = "https://foundry.cognitiveservices.azure.com/openai/deployments/gpt-4o-mini"
      WEBUI_AUTH          = "False"
    }
  }

  assert {
    condition     = azurerm_linux_web_app.this.app_settings["WEBUI_AUTH"] == "False"
    error_message = "WEBUI_AUTH app setting was not propagated."
  }

  assert {
    condition     = startswith(azurerm_linux_web_app.this.app_settings["OPENAI_API_KEY"], "@Microsoft.KeyVault(")
    error_message = "OPENAI_API_KEY should be a Key Vault reference."
  }
}

run "plan_with_diagnostics" {
  command = plan

  variables {
    name                                  = "app-diag"
    resource_group_name                   = "rg-unit-test"
    location                              = "westeurope"
    diagnostic_log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/law"
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this) == 1
    error_message = "Diagnostic setting should be created when a workspace ID is provided."
  }
}

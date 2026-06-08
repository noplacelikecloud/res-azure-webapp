output "id" {
  description = "Full Azure resource ID of the Linux Web App."
  value       = azurerm_linux_web_app.this.id
}

output "name" {
  description = "Web App name."
  value       = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  description = "Default hostname of the web app (e.g. <name>.azurewebsites.net)."
  value       = azurerm_linux_web_app.this.default_hostname
}

output "principal_id" {
  description = "System-Assigned Managed Identity principal ID. Null when system identity is not enabled."
  value = (
    var.identity_type == "SystemAssigned" || var.identity_type == "SystemAssigned, UserAssigned"
    ? azurerm_linux_web_app.this.identity[0].principal_id
    : null
  )
}

output "service_plan_id" {
  description = "Resource ID of the associated App Service Plan."
  value       = azurerm_service_plan.this.id
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint (null when none was created)."
  value       = length(azurerm_private_endpoint.this) > 0 ? azurerm_private_endpoint.this[0].id : null
}

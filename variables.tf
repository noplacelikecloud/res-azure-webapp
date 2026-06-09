variable "name" {
  description = "Name of the Linux Web App (also used as default for the associated App Service Plan)."
  type        = string

  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 60
    error_message = "Web App name must be between 2 and 60 characters."
  }
}

variable "resource_group_name" {
  description = "Resource group in which the web app and service plan are created."
  type        = string
}

variable "location" {
  description = "Azure region for the web app and service plan."
  type        = string
}

variable "service_plan" {
  description = "App Service Plan configuration. os_type is fixed to Linux."
  type = object({
    name     = optional(string)
    sku_name = optional(string, "B1")
  })
  default = {}
}

variable "container" {
  description = "Container image to host. Defaults to the Open WebUI image on GHCR."
  type = object({
    image        = optional(string, "open-webui/open-webui:main")
    registry_url = optional(string, "https://ghcr.io")
  })
  default = {}
}

variable "app_settings" {
  description = "Map of application settings (env vars) injected into the container."
  type        = map(string)
  default     = {}
}

variable "https_only" {
  description = "Force HTTPS-only traffic."
  type        = bool
  default     = true
}

variable "identity_type" {
  description = "Managed identity type. One of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, None."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned", "None"], var.identity_type)
    error_message = "identity_type must be SystemAssigned, UserAssigned, 'SystemAssigned, UserAssigned' or None."
  }
}

variable "user_assigned_identity_ids" {
  description = "List of user-assigned managed identity IDs, used when identity_type includes UserAssigned."
  type        = list(string)
  default     = []
}

variable "public_network_access_enabled" {
  description = "Whether the web app is reachable from the public internet."
  type        = bool
  default     = true
}

variable "private_endpoint" {
  description = <<-EOT
    Optional private endpoint configuration. When set, a private
    endpoint targeting the 'sites' subresource is created.
  EOT
  type = object({
    name                 = optional(string)
    subnet_id            = string
    private_dns_zone_ids = optional(list(string), [])
  })
  default = null
}

variable "diagnostic_log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace ID. When set, a diagnostic setting forwarding AppServiceHTTPLogs and AllMetrics is created."
  type        = string
  default     = null
}

variable "enable_diagnostic_settings" {
  description = <<-EOT
    Whether to create the diagnostic setting. When null (the default),
    creation is derived from whether diagnostic_log_analytics_workspace_id
    is set. Set this explicitly to true/false when the workspace ID is
    computed (e.g. another module's output) and therefore unknown at
    plan time, so Terraform can determine the resource count.
  EOT
  type        = bool
  default     = null
}

variable "tags" {
  description = "Map of tags applied to the web app and service plan."
  type        = map(string)
  default     = {}
}

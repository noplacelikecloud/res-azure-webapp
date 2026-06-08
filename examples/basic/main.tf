terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "webapp" {
  source = "../.."

  name                = "app-example-001"
  resource_group_name = "rg-example"
  location            = "westeurope"
}

output "default_hostname" {
  value = module.webapp.default_hostname
}

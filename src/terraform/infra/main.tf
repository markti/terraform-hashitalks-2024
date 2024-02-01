resource "random_string" "main" {
  length  = 8
  upper   = false
  special = false
}

data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location = var.primary_region
}
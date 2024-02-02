resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
}

resource "azurerm_key_vault_secret" "app_insights_instrumentation_key" {
  key_vault_id = azurerm_key_vault.main.id
  name         = "app-insights-connection-string"
  value        = azurerm_application_insights.main.instrumentation_key
}
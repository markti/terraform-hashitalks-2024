resource "azurerm_virtual_network" "main" {

  name                = "vnet-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.address_space]

}


module "network_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_virtual_network.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs                       = ["VMProtectionAlerts"]

}

data "azurerm_virtual_network" "github_runner" {
  name                = var.github_runner_network.virtual_network_name
  resource_group_name = var.github_runner_network.resource_group_name
}

locals {
  alpha = {
    rg   = azurerm_resource_group.main.name
    name = azurerm_virtual_network.main.name
    id   = azurerm_virtual_network.main.id
  }
  beta = {
    rg   = data.azurerm_virtual_network.github_runner.resource_group_name
    name = data.azurerm_virtual_network.github_runner.name
    id   = data.azurerm_virtual_network.github_runner.id
  }
}

resource "azurerm_virtual_network_peering" "a-to-b" {
  name                      = "workload-to-github-runner"
  resource_group_name       = local.alpha.rg
  virtual_network_name      = local.alpha.name
  remote_virtual_network_id = local.beta.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "b-to-a" {
  name                      = "github-runner-to-workload"
  resource_group_name       = local.beta.rg
  virtual_network_name      = local.beta.name
  remote_virtual_network_id = local.alpha.id
  allow_forwarded_traffic   = true
}
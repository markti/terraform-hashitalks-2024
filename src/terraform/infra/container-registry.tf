
resource "azurerm_container_registry" "main" {
  name                          = "cr${var.application_name}${var.environment_name}${random_string.main.result}"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  sku                           = "Premium"
  zone_redundancy_enabled       = true
  admin_enabled                 = true
  data_endpoint_enabled         = false
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  network_rule_set {
    default_action = "Deny"
  }

}

resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_workload" {
  name                  = "dns-link-acr-workload"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

resource "azurerm_private_endpoint" "acr" {
  name                = "pep-${azurerm_container_registry.main.name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.shared.id

  private_service_connection {
    name                           = "${azurerm_container_registry.main.name}-link"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "acr-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }
}

module "acr_pep_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_private_endpoint.acr.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

}
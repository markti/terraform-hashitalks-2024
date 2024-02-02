resource "azurerm_key_vault" "main" {
  name                          = "kv-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location                      = azurerm_resource_group.main.location
  resource_group_name           = azurerm_resource_group.main.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  purge_protection_enabled      = false
}

resource "azurerm_key_vault_secret" "sauce" {
  name         = "secret-sauce"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_virtual_network_peering.a-to-b, azurerm_virtual_network_peering.b-to-a]
}

resource "azurerm_role_assignment" "terraform_keyvault_access" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

module "keyvault_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_key_vault.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs                       = ["AuditEvent", "AzurePolicyEvaluationDetails"]

}

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_workload" {
  name                  = "dns-link-keyvault-workload"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_github_runner" {
  name                  = "dns-link-keyvault-github-runner"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = data.azurerm_virtual_network.github_runner.id
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = "pep-${azurerm_key_vault.main.name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = azurerm_subnet.shared.id

  private_service_connection {
    name                           = "${azurerm_key_vault.main.name}-link"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "vault-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]
  }
}

module "kv_pep_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_private_endpoint.keyvault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

}
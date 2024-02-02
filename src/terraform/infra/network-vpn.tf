# Enterprise Application used to grant access to Azure VPN
# In order to use this, you need to authenticate Terraform with sufficient credentials to create enterprise applications
resource "azuread_application" "vpn" {

  count = var.vpn_application_id == null ? 1 : 0

  display_name = "${var.application_name}-${var.environment_name}-${random_string.main.result}-vpn"

}

resource "azurerm_public_ip" "vpn" {
  name                = "pip-vgw-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku               = "Standard"
  zones             = [1, 2, 3]
  allocation_method = "Static"

}

module "vpn_pip_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_public_ip.vpn.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs = [
    "DDoSProtectionNotifications",
    "DDoSMitigationFlowLogs",
    "DDoSMitigationReports"
  ]

}

resource "azurerm_virtual_network_gateway" "main" {
  name                = "vgw-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1AZ"

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vpn.id
  }

  vpn_client_configuration {
    address_space        = [var.vpn_address_space]
    vpn_client_protocols = ["OpenVPN"]
    vpn_auth_types       = ["AAD"]
    aad_tenant           = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
    aad_audience         = var.vpn_application_id == null ? azuread_application.vpn[0].client_id : var.vpn_application_id
    aad_issuer           = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"
  }
}

module "vpn_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_virtual_network_gateway.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs = [
    "GatewayDiagnosticLog",
    "TunnelDiagnosticLog",
    "RouteDiagnosticLog",
    "IKEDiagnosticLog",
    "P2SDiagnosticLog"
  ]

}
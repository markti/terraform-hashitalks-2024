resource "azurerm_public_ip" "vpn" {
  name                = "pip-vgw-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku               = "Standard"
  zones             = [1, 2, 3]
  allocation_method = "Static"

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
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.vpn.id
  }

  vpn_client_configuration {
    address_space        = [var.vpn_address_space]
    vpn_client_protocols = ["OpenVPN"]
    vpn_auth_types       = ["AAD"]
    aad_tenant           = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}"
    aad_audience         = ""
    aad_issuer           = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/"

  }
}

resource "azuread_application" "vpn" {

  count = var.vpn_application_id == null ? 1 : 0

  display_name = "${var.application_name}-${var.environment_name}-${random_string.main.result}-vpn"

}
resource "azurerm_virtual_network" "main" {

  name                = "vnet-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.address_space]

}


resource "azurerm_subnet" "gateway" {

  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 5, 0)]

}

# minimum subnet size of /28
# https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview
resource "azurerm_subnet" "dns_resolver" {

  name                 = "DnsResolverSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 5, 1)]

}

resource "azurerm_subnet" "app_gateway" {

  name                 = "AppGatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 2)]

}

resource "azurerm_subnet" "shared" {

  name                 = "snet-shared"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 3)]

}

resource "azurerm_subnet" "workload" {

  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 4)]

}

module "azure-terraformer" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.7"

  resource_id                = azurerm_virtual_network.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs                       = ["VMProtectionAlerts"]

}
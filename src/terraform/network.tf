resource "azurerm_virtual_network" "main" {

  name                = "vnet-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.address_space]

}


resource "azurerm_subnet" "vpn" {

  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 5, 0)]

}

# minimum subnet size of /28
# https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview
resource "azurerm_subnet" "dns" {

  name                 = "DnsResolverSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 5, 1)]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      name = "Microsoft.Network/dnsResolvers"
    }
  }

}

# minimum subnet size of /26
# recommendation of /24 for future support of WAF
# https://learn.microsoft.com/en-us/azure/application-gateway/configuration-infrastructure
resource "azurerm_subnet" "app_gateway" {

  name                 = "AppGatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 1)]

}

resource "azurerm_subnet" "shared" {

  name                 = "snet-shared"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 2)]

}

resource "azurerm_subnet" "workload" {

  name                 = "snet-workload"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space, 2, 3)]

}

module "network_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_virtual_network.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs                       = ["VMProtectionAlerts"]

}

resource "random_string" "flowlogs" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_storage_account" "flowlogs" {
  name                     = "stlogs${random_string.flowlogs.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GZRS"
}
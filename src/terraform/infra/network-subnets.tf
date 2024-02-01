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
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
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
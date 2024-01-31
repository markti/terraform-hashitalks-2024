
resource "azurerm_private_dns_resolver" "main" {

  name                = "dnspr-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  virtual_network_id  = azurerm_virtual_network.main.id

}

resource "azurerm_private_dns_resolver_inbound_endpoint" "main" {

  name                    = azurerm_private_dns_resolver.main.name
  private_dns_resolver_id = azurerm_private_dns_resolver.main.id
  location                = azurerm_private_dns_resolver.main.location

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.dns.id
  }

}
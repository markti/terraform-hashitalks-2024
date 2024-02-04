
resource "azurerm_public_ip" "app_gateway" {
  name                = "pip-agw-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  sku                     = "Standard"
  zones                   = [1, 2, 3]
  allocation_method       = "Static"
  idle_timeout_in_minutes = 4

}

module "agw_pip_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_public_ip.app_gateway.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs = [
    "DDoSProtectionNotifications",
    "DDoSMitigationFlowLogs",
    "DDoSMitigationReports"
  ]

}

locals {
  backend_ip_address = cidrhost(azurerm_subnet.workload.address_prefixes[0], 250)
}

resource "azurerm_application_gateway" "main" {
  name                = "agw-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku {
    name = var.app_gateway_configuration.sku
    tier = var.app_gateway_configuration.sku
  }
  zones        = [1, 2, 3]
  enable_http2 = false

  autoscale_configuration {
    min_capacity = var.app_gateway_configuration.capacity.min
    max_capacity = var.app_gateway_configuration.capacity.max
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.app_gateway.id
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_ip_configuration {
    name                          = "appGwPublicFrontendIp"
    public_ip_address_id          = azurerm_public_ip.app_gateway.id
    private_ip_address_allocation = "Dynamic"
  }

  backend_address_pool {
    name         = "myBackendPool"
    ip_addresses = [local.backend_ip_address]
  }

  backend_http_settings {
    name                  = "healthCheckSettings"
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout       = 20
    probe_name            = "healthCheck"
  }

  url_path_map {
    name                               = "httpRule"
    default_backend_address_pool_name  = "myBackendPool"
    default_backend_http_settings_name = "healthCheckSettings"

    path_rule {
      name                       = "health-check"
      paths                      = ["/api/HealthCheck/*"]
      backend_address_pool_name  = "myBackendPool"
      backend_http_settings_name = "healthCheckSettings"
    }
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
    require_sni                    = false
  }

  request_routing_rule {
    name               = "httpRule"
    priority           = 1
    rule_type          = "PathBasedRouting"
    http_listener_name = "httpListener"
    url_path_map_name  = "httpRule"
  }

  probe {
    name                                      = "healthCheck"
    protocol                                  = "Http"
    host                                      = "127.0.0.1"
    path                                      = "/api/HealthCheck/healthz/ready"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
    minimum_servers                           = 0
  }

}

module "agw_monitor_diagnostic" {
  source  = "markti/azure-terraformer/azurerm//modules/monitor/diagnostic-setting/rando"
  version = "1.0.10"

  resource_id                = azurerm_application_gateway.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayPerformanceLog",
    "ApplicationGatewayFirewallLog"
  ]

}
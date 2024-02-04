
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

  backend_address_pool_name      = "myBackendPool"
  frontend_ip_configuration_name = "appGwPublicFrontendIp"
  backend_http_settings_name     = "healthCheckSettings"
  probe_name                     = "healthCheck"
  url_path_map_name              = "httpRule"
  http_listener_name             = "httpListener"
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
    name                          = local.frontend_ip_configuration_name
    public_ip_address_id          = azurerm_public_ip.app_gateway.id
    private_ip_address_allocation = "Dynamic"
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = [local.backend_ip_address]
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout       = 20
    probe_name            = local.probe_name
  }

  url_path_map {
    name                               = local.url_path_map_name
    default_backend_address_pool_name  = local.backend_address_pool_name
    default_backend_http_settings_name = local.backend_http_settings_name

    path_rule {
      name                       = "health-check"
      paths                      = ["/api/HealthCheck/*"]
      backend_address_pool_name  = local.backend_address_pool_name
      backend_http_settings_name = local.backend_http_settings_name
    }
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = "port_80"
    protocol                       = "Http"
    require_sni                    = false
  }

  request_routing_rule {
    name               = local.url_path_map_name
    priority           = 1
    rule_type          = "PathBasedRouting"
    http_listener_name = local.http_listener_name
    url_path_map_name  = local.url_path_map_name
  }

  probe {
    name                                      = local.probe_name
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
resource "azurerm_cdn_frontdoor_profile" "main" {
  name                     = "afd-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  resource_group_name      = azurerm_resource_group.main.name
  sku_name                 = "Standard_AzureFrontDoor"
  response_timeout_seconds = 90
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "fde-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  enabled                  = true
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "default-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  health_probe {
    path                = "/api/HealthCheck/healthz/live"
    protocol            = "Http"
    request_type        = "GET"
    interval_in_seconds = 100
  }

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }
}

resource "azurerm_cdn_frontdoor_origin" "main" {
  name                           = "default-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.main.id
  enabled                        = true
  certificate_name_check_enabled = false
  host_name                      = azurerm_public_ip.app_gateway.ip_address
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_public_ip.app_gateway.ip_address
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "default-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.main.id]
  enabled                       = true
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "HttpOnly"
  https_redirect_enabled        = true
}
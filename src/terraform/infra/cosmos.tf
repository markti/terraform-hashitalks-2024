resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmos-${var.application_name}-${var.environment_name}-${random_string.main.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = var.primary_region
    failover_priority = 0
  }

  capacity {
    total_throughput_limit = 400
  }

}

resource "azurerm_role_assignment" "workload_identity_cosmos_reader" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Cosmos DB Account Reader"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}
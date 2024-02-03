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
  scope                = azurerm_cosmosdb_account.main.id
  role_definition_name = "DocumentDB Account Contributor"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}

resource "azurerm_cosmosdb_sql_role_definition" "reader" {
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  name                = "CosmosDB Reader"
  assignable_scopes   = ["/"]

  permissions {
    data_actions = [
      "Microsoft.DocumentDB/databaseAccounts/readMetadata",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/readChangeFeed"
    ]
  }
}

resource "azurerm_cosmosdb_sql_role_definition" "writer" {
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  name                = "CosmosDB Writer"
  assignable_scopes   = ["/"]

  permissions {
    data_actions = [
      "Microsoft.DocumentDB/databaseAccounts/readMetadata",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*"
    ]
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "workload_identity" {
  name                = azurerm_user_assigned_identity.workload.name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name

  scope              = azurerm_cosmosdb_account.main.id
  role_definition_id = azurerm_cosmosdb_sql_role_definition.writer.id
  principal_id       = azurerm_user_assigned_identity.workload.principal_id
}
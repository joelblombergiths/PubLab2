//Create a Cosmos DB account
resource "azurerm_cosmosdb_account" "CosmosDb" {
  name                = "lab2cosmosdbjb"
  resource_group_name = local.RGName
  location            = local.RGLocation
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
  geo_location {
    location          = local.RGLocation
    failover_priority = 0
  }
  depends_on = [azurerm_resource_group.rg]
}

//Create a Cosmos DB database
resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "TodoItems"
  resource_group_name = local.RGName
  account_name        = azurerm_cosmosdb_account.CosmosDb.name
  throughput          = 400

  depends_on = [azurerm_cosmosdb_account.CosmosDb]
}

//Create a Cosmos DB container
resource "azurerm_cosmosdb_sql_container" "container" {
  name                  = "Items"
  resource_group_name   = local.RGName
  account_name          = azurerm_cosmosdb_account.CosmosDb.name
  database_name         = azurerm_cosmosdb_sql_database.db.name
  partition_key_path    = "/partition"
  partition_key_version = 1
  throughput            = 400

  indexing_policy {
    indexing_mode = "consistent"
  }

  depends_on = [ azurerm_cosmosdb_sql_database.db ]
}


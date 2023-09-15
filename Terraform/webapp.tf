resource "azurerm_service_plan" "SP" {
  name                = "Lab2ServicePlan-JB"
  resource_group_name = local.RGName
  location            = local.RGLocation
  os_type             = "Linux"
  sku_name            = "B1"
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_linux_web_app" "WebApp" {
  name                = "Lab2WebApp-JB"
  resource_group_name = local.RGName
  location            = local.RGLocation
  service_plan_id     = azurerm_service_plan.SP.id

  site_config {
    application_stack {
      dotnet_version = "7.0"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "cosmosDatabaseId"               = azurerm_cosmosdb_sql_database.db.name
    "cosmosContainerId"              = azurerm_cosmosdb_sql_container.container.name
  }

  connection_string {
    name  = "CosmosDB"
    type  = "Custom"
    value = azurerm_cosmosdb_account.CosmosDb.connection_strings[0]
  }

  depends_on = [azurerm_service_plan.SP, azurerm_cosmosdb_sql_container.container]
}

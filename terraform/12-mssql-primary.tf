# Create azure sql db - primary.
module "az_mssql_primary" {
  source              = "./modules/az_mssql_primary"                                          # The path to the module.
  location            = var.location_primary                                                  # SQL primary location.
  resource_group_name = azurerm_resource_group.rg.name                                        # The resource group.
  sql_primary_name    = "sql-${var.environment}-${var.application_code}-${var.unique_id}-pri" # SQL primary name.
  sql_db_name         = var.sql_db_name                                                       # SQL db name.
}

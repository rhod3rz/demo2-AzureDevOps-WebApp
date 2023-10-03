# Create azure sql db - secondary.
module "az_mssql_secondary" {
  depends_on          = [module.az_mssql_primary]
  count               = var.environment == "prd" ? 1 : 0                                      # Conditionally create the resource.
  source              = "./modules/az_mssql_secondary"                                        # The path to the module.
  location            = var.location_secondary                                                # SQL secondary location.
  resource_group_name = azurerm_resource_group.rg.name                                        # The resource group.
  sql_secondary_name  = "sql-${var.environment}-${var.application_code}-${var.unique_id}-sec" # SQL secondary name.
  failover_group_name = var.unique_id                                                         # The name of the failover group.
  sql_primary_id      = module.az_mssql_primary.sql_primary_id                                # SQL primary id - required for failover config.
  sql_database_db_id  = module.az_mssql_primary.sql_database_db_id                            # Database id - required for failover config.
}

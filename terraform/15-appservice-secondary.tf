# Create app service - secondary.
module "az_appservice_secondary" {
  depends_on = [module.az_mssql_primary,
  module.az_mssql_secondary]
  count                = var.environment == "prd" ? 1 : 0                                      # Conditionally create the resource.
  source               = "./modules/az_appservice"                                             # The path to the module.
  location             = var.location_secondary                                                # SQL location.
  resource_group_name  = azurerm_resource_group.rg.name                                        # The resource group.
  plan_name            = "pln-${var.environment}-${var.application_code}-${var.unique_id}-sec" # The plan name.
  webapp_name          = "app-${var.environment}-${var.application_code}-${var.unique_id}-sec" # The webapp name.
  ai_connection_string = module.az_base.ai_connection_string                                   # The app insight connection string.
  acr_login_server     = "https://acrdlnteudemoapps210713.azurecr.io"                          # The acr server.
  acr_admin_username   = "acrdlnteudemoapps210713"                                             # The acr username.
  connection_string    = module.az_mssql_secondary[0].connection_string_failover               # The db connection string.
  law_id               = module.az_base.law_id                                                 # The log analytics workspace id.
  autoscale_name       = "autoscale-${var.location_secondary}"                                 # The autoscale setting name.
}

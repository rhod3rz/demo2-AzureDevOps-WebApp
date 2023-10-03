# Create app service - dev.
module "az_appservice_dev" {
  depends_on           = [module.az_mssql_primary]
  count                = var.environment == "dev" ? 1 : 0                                  # Conditionally create the resource.
  source               = "./modules/az_appservice"                                         # The path to the module.
  location             = var.location_primary                                              # SQL location.
  resource_group_name  = azurerm_resource_group.rg.name                                    # The resource group.
  plan_name            = "pln-${var.environment}-${var.application_code}-${var.unique_id}" # The plan name.
  webapp_name          = "app-${var.environment}-${var.application_code}-${var.unique_id}" # The webapp name.
  ai_connection_string = module.az_base.ai_connection_string                               # The app insight connection string.
  acr_login_server     = "https://acrdlnteudemoapps210713.azurecr.io"                      # The acr server.
  acr_admin_username   = "acrdlnteudemoapps210713"                                         # The acr username.
  connection_string    = module.az_mssql_primary.connection_string_primary                 # The db connection string.
  law_id               = module.az_base.law_id                                             # The log analytics workspace id.
  autoscale_name       = "autoscale-${var.location_primary}"                               # The autoscale setting name.
}

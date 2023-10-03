# Create frontdoor.
module "az_frontdoor" {
  depends_on = [module.az_appservice_primary,
    module.az_appservice_secondary,
  module.az_dns]
  count                  = var.environment == "prd" ? 1 : 0                                          # Conditionally create the resource.
  source                 = "./modules/az_frontdoor"                                                  # The path to the module.
  resource_group_name    = azurerm_resource_group.rg.name                                            # The resource group.
  fd_name                = "fd-${var.unique_id}"                                                     # The front door name.
  be_prd_rhod3rz_com_pri = "app-${var.environment}-${var.application_code}-${var.unique_id}-pri"     # The webapp name - prd pri.
  be_prd_rhod3rz_com_sec = "app-${var.environment}-${var.application_code}-${var.unique_id}-sec"     # The webapp name - prd sec.
  be_stg_rhod3rz_com_pri = "app-${var.environment}-${var.application_code}-${var.unique_id}-pri-stg" # The webapp name - stg pri.
  be_stg_rhod3rz_com_sec = "app-${var.environment}-${var.application_code}-${var.unique_id}-sec-stg" # The webapp name - stg sec.
}

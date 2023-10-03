# Create sql server - primary.
resource "azurerm_mssql_server" "primary" {
  location                     = var.location
  resource_group_name          = var.resource_group_name
  name                         = var.sql_primary_name
  administrator_login          = "azuresql"
  administrator_login_password = data.azurerm_key_vault_secret.kv_sql_admin_password.value
  version                      = "12.0"
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Create sql server firewall rule.
# The feature 'Allow Azure services and resources to access this server' is enabled by setting start_ip_address and end_ip_address to 0.0.0.0.
resource "azurerm_mssql_firewall_rule" "allowAzureServices" {
  name             = "allowAzureServices"
  server_id        = azurerm_mssql_server.primary.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Create sql server firewall rule - add home public ip for testing.
resource "azurerm_mssql_firewall_rule" "allowHomeServices" {
  name             = "allowHomeServices"
  server_id        = azurerm_mssql_server.primary.id
  start_ip_address = "86.10.95.19"
  end_ip_address   = "86.10.95.19"
}

# Create a database.
resource "azurerm_mssql_database" "db" {
  depends_on   = [azurerm_mssql_firewall_rule.allowAzureServices, azurerm_mssql_firewall_rule.allowAzureServices]
  name         = var.sql_db_name
  server_id    = azurerm_mssql_server.primary.id
  collation    = "SQL_LATIN1_GENERAL_CP1_CI_AS"
  create_mode  = "Default"
  license_type = "LicenseIncluded"
  sku_name     = "S0"
  lifecycle {
    ignore_changes = all
  }
}

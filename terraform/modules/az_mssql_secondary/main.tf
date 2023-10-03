# Create sql server - secondary.
resource "azurerm_mssql_server" "secondary" {
  location                     = var.location
  resource_group_name          = var.resource_group_name
  name                         = var.sql_secondary_name
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
  server_id        = azurerm_mssql_server.secondary.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Create sql server firewall rule - add home public ip for testing.
resource "azurerm_mssql_firewall_rule" "allowHomeServices" {
  name             = "allowHomeServices"
  server_id        = azurerm_mssql_server.secondary.id
  start_ip_address = "86.10.95.19"
  end_ip_address   = "86.10.95.19"
}

# Create the failover group.
resource "azurerm_mssql_failover_group" "sfg" {
  depends_on = [azurerm_mssql_server.secondary]
  name       = var.failover_group_name
  server_id  = var.sql_primary_id
  databases  = [var.sql_database_db_id]
  partner_server {
    id = azurerm_mssql_server.secondary.id
  }
  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

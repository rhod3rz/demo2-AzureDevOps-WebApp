output "sql_primary_id" { value = azurerm_mssql_server.primary.id }
output "sql_database_db_id" { value = azurerm_mssql_database.db.id }
output "connection_string_primary" { value = "Server=tcp:${azurerm_mssql_server.primary.name}.database.windows.net,1433;Initial Catalog=${var.sql_db_name};Persist Security Info=False;User ID=azuresql;Password=${data.azurerm_key_vault_secret.kv_sql_admin_password.value};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" }

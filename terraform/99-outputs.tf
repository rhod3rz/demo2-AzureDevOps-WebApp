# BASE
output "base_law_id" { value = module.az_base.law_id }

# MSSQL PRIMARY
output "mssql_pri_sql_primary_id" { value = module.az_mssql_primary.sql_primary_id }
output "mssql_pri_sql_database_db_id" { value = module.az_mssql_primary.sql_database_db_id }

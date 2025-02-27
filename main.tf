provider "azurerm" {
  client_id       = "5f673f24-669f-4bd9-9a0b-3f96a7342654"  # appId (Client ID)
  client_secret   = "rOa8Q~xXEjVr2Pcf_gHf4md1Hia0S8kruXqwLcJv"  # password (Client Secret)
  subscription_id = "eb790b59-ab45-4869-82c5-7b06dcfd6184"  # Azure Subscription ID
  tenant_id       = "91a8fddf-7ed5-4867-b541-e85a402cf168"  # Tenant ID
  features {}
}

# Step 1: Creating a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

# Step 2: Create a SQL Server
resource "azurerm_mssql_server" "server" {
  name                         = "sql-server-terr"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "adminpassword@_@23"
}

# Step 3: Create SQL Elastic Pool
resource "azurerm_mssql_elasticpool" "sql-elasticpool" {
  location            = azurerm_resource_group.example.location
  name                = "kavsql-elasticpool"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mssql_server.server.name

  max_size_gb = 9.7656250

  sku {
    name     = "BasicPool"
    tier     = "Basic"
    capacity = 100
  }

  per_database_settings {
    min_capacity = 0
    max_capacity = 5
  }
}

# Step 4: Create Databases (5 in Elastic Pool, 1 separate)
resource "azurerm_mssql_database" "platform_db" {
  name            = "platformdb"
  server_id       = azurerm_mssql_server.server.id
  elastic_pool_id = azurerm_mssql_elasticpool.sql-elasticpool.id
}

resource "azurerm_mssql_database" "crm_db" {
  name            = "crmdb"
  server_id       = azurerm_mssql_server.server.id
  elastic_pool_id = azurerm_mssql_elasticpool.sql-elasticpool.id
}

resource "azurerm_mssql_database" "cfo_db" {
  name            = "cfodb"
  server_id       = azurerm_mssql_server.server.id
  elastic_pool_id = azurerm_mssql_elasticpool.sql-elasticpool.id
}

resource "azurerm_mssql_database" "background_db" {
  name            = "backgrounddb"
  server_id       = azurerm_mssql_server.server.id
  elastic_pool_id = azurerm_mssql_elasticpool.sql-elasticpool.id
}

resource "azurerm_mssql_database" "pfm_db" {
  name            = "pfmdb"
  server_id       = azurerm_mssql_server.server.id
  elastic_pool_id = azurerm_mssql_elasticpool.sql-elasticpool.id
}

# Step 5: Create Logs DB (outside of Elastic Pool)
resource "azurerm_mssql_database" "logs_db" {
  name      = "logsdb"
  server_id = azurerm_mssql_server.server.id
}

# Step 6: Outputs (Connection Strings for all databases)
output "platform_db_connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.server.name}.database.windows.net,1433;Database=platformdb;User ID=OwnerPlatform;Password=password123;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
}

output "crm_db_connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.server.name}.database.windows.net,1433;Database=crmdb;User ID=OwnerCRM;Password=password123;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
}

output "cfo_db_connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.server.name}.database.windows.net,1433;Database=cfodb;User ID=OwnerCFO;Password=password123;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
}

output "background_db_connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.server.name}.database.windows.net,1433;Database=backgrounddb;User ID=OwnerBackground;Password=password123;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
}

output "pfm_db_connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.server.name}.database.windows.net,1433;Database=pfmdb;User ID=OwnerPFM;Password=password123;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
}

output "logs_db_connection_string" {
  value = "Server=tcp:${azurerm_mssql_server.server.name}.database.windows.net,1433;Database=logsdb;User ID=OwnerLogs;Password=password123;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
}

# Step 7: Create Key Vault for storing connection strings
resource "azurerm_key_vault" "kv_1" {
  name                = "example-kv-1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = "91a8fddf-7ed5-4867-b541-e85a402cf168"  # Replace with your actual tenant ID
  sku_name            = "standard"
  access_policy {
    tenant_id = "91a8fddf-7ed5-4867-b541-e85a402cf168"  # Replace with your actual tenant ID
    object_id = "512b2380-217a-4917-a09b-bb4aed95b2d4"  # Replace with the actual Object ID

    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete"
    ]
  }
}

# Step 8: Create Key Vault 2 for another purpose
resource "azurerm_key_vault" "kv_2" {
  name                = "example-kv-2"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = "91a8fddf-7ed5-4867-b541-e85a402cf168"  # Replace with your actual tenant ID
  sku_name            = "standard"
}

# Step 9: Create Key Vault Secrets for platform DB connection string
resource "azurerm_key_vault_secret" "platform_db_connection_string" {
  name         = "platform-db-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.server.fully_qualified_domain_name},1433;Initial Catalog=platformdb;Persist Security Info=False;User ID=sqladmin;Password=Password123!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv_1.id
}

resource "azurerm_key_vault_secret" "crm_db_connection_string" {
  name         = "crm-db-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.server.fully_qualified_domain_name},1433;Initial Catalog=crmdb;Persist Security Info=False;User ID=sqladmin;Password=Password123!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv_1.id
}

resource "azurerm_key_vault_secret" "logs_db_connection_string" {
  name         = "logs-db-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.server.fully_qualified_domain_name},1433;Initial Catalog=logsdb;Persist Security Info=False;User ID=sqladmin;Password=Password123!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv_1.id
}

resource "azurerm_key_vault_secret" "pfm_db_connection_string" {
  name         = "pfm-db-connection-string"
  value        = "Server=tcp:${azurerm_mssql_server.server.fully_qualified_domain_name},1433;Initial Catalog=pfmdb;Persist Security Info=False;User ID=sqladmin;Password=Password123!;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.kv_1.id
}

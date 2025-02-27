# Azure Provider Configuration
provider "azurerm" {
  features = {}
}

# Resource Group to hold all resources
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

# Random ID to ensure unique names
resource "random_id" "server_id" {
  byte_length = 8
}

# SQL Server Setup
resource "azurerm_mssql_server" "server" {
  name                         = "sql-server-${random_id.server_id.hex}"  # Unique name for the server
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "adminpassword@_@23"
}

# SQL Elastic Pool Setup
resource "azurerm_mssql_elasticpool" "sql-elasticpool" {
  location            = azurerm_resource_group.example.location
  name                = "kavsql-elasticpool"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_mssql_server.server.name
  max_size_gb         = 50  # Corrected minimum value for the Basic Tier

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

# Creating Databases in Elastic Pool
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

# Creating a database outside of the Elastic Pool
resource "azurerm_mssql_database" "logs_db" {
  name      = "logsdb"
  server_id = azurerm_mssql_server.server.id
}

# Azure Key Vault 1 Setup
resource "azurerm_key_vault" "kv_1" {
  name                = "example-kv-1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = "91a8fddf-7ed5-4867-b541-e85a402cf168"
  sku_name            = "standard"

  access_policy {
    tenant_id = "91a8fddf-7ed5-4867-b541-e85a402cf168"
    object_id = "512b2380-217a-4917-a09b-bb4aed95b2d4"  # Update with correct Object ID

    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Delete"
    ]
  }
}

# Key Vault Secrets for each database connection string
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

# Azure Key Vault 2 Setup (for additional purpose


# App Service Plan
resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"  # Specify "Linux" for Linux apps, or omit for Windows
  reserved            = true     # Set to true for Linux-based app services

  sku {
    tier = "Standard"  # Options like "Basic", "Premium", etc.
    size = "S1"        # This can be S1, P1v2, etc.
  }
}

# First App Service
resource "azurerm_app_service" "app_service_1" {
  name                = "example-app-service-1"   # Unique name for the first app service
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"   # Specify the .NET framework version if you're using it
    scm_type                 = "LocalGit" # Optionally configure Git deployment
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

# Second App Service
resource "azurerm_app_service" "app_service_2" {
  name                = "example-app-service-2"   # Unique name for the second app service
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"   # Specify the .NET framework version if you're using it
    scm_type                 = "LocalGit" # Optionally configure Git deployment
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

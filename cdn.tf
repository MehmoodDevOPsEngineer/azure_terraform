
# Storage Account (for the origin)
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
}

# CDN Profile
resource "azurerm_cdn_profile" "example" {
  name                = "example-cdn-profile"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard_Verizon"  # You can change this to another SKU like "Standard_Akamai" or "Premium_Verizon"
}

# CDN Endpoint with Storage as Origin
resource "azurerm_cdn_endpoint" "example" {
  name                = "example-cdn-endpoint"
  resource_group_name = azurerm_resource_group.example.name
  profile_name        = azurerm_cdn_profile.example.name
  location            = azurerm_resource_group.example.location  # Added the location argument here
  origin_host_header  = azurerm_storage_account.example.primary_web_endpoint
  origin_path         = "/"  # Adjust this if you want to serve a specific path from the Blob Storage
  is_https_allowed    = true

  origin {
    name      = "example-origin"
    host_name = azurerm_storage_account.example.primary_web_endpoint
    http_port = 80
    https_port = 443
  }

  tags = {
    environment = "production"
  }
}


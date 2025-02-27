# Azure Cache for Redis for offloading the load 
resource "azurerm_redis_cache" "example" {
  name                = "example-redis-cache"  # Must be globally unique
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "Basic"                # Correct argument for SKU
  capacity            = 1                       # The capacity (valid range is 1-6 for Basic tier)
  family              = "C"                     # Redis family "C" (current generation)

  tags = {
    environment = "production"
    purpose     = "cache"
  }
}

# Output the Redis Cache Name and Hostname
output "redis_cache_name" {
  value = azurerm_redis_cache.example.name
}

output "redis_cache_hostname" {
  value = azurerm_redis_cache.example.hostname
}

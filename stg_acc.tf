
# Storage Account 1: For storing compiled UI files
resource "azurerm_storage_account" "ui_files" {
  name                     = "uifilesaccount"  # Must be globally unique
  resource_group_name       = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier              = "Standard"
  account_replication_type = "LRS"  # Locally redundant storage (LRS)

  tags = {
    environment = "production"
    purpose     = "compiled-ui-files"
  }
}

# Storage Account 2: For storing documents (LetsEncrypt file, attachments, etc.)
resource "azurerm_storage_account" "documents" {
  name                     = "docsaccount"  # Must be globally unique
  resource_group_name       = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier              = "Standard"
  account_replication_type = "LRS"  # Locally redundant storage (LRS)

  tags = {
    environment = "production"
    purpose     = "documents-storage"
  }
}

# Output the storage account names
output "ui_files_storage_account" {
  value = azurerm_storage_account.ui_files.name
}

output "documents_storage_account" {
  value = azurerm_storage_account.documents.name
}

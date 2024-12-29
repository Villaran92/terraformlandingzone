### CUENTAS DE ALMACENAMIENTO ###

resource "azurerm_storage_account" "data" {
  name                          = lower("${local.client}data")
  resource_group_name           = azurerm_resource_group.rg-prod["Critical-App"].name
  location                      = local.location
  account_tier                  = "Standard"
  account_replication_type      = "ZRS"
  public_network_access_enabled = false
  tags = merge(local.tags, {
    Recurso = "Cuenta de almacenamiento"
    Uso     = "General"
  })
}

resource "azurerm_storage_account" "intune" {
  name                          = lower("${local.client}intune")
  resource_group_name           = azurerm_resource_group.rg-prod["Critical-App"].name
  location                      = local.location
  account_tier                  = "Standard"
  account_replication_type      = "ZRS"
  public_network_access_enabled = true
  tags = merge(local.tags, {
    Recurso = "Cuenta de almacenamiento"
    Uso     = "Intune"
  })
}


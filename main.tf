### RECURSOS PRINCIPALES MONITORIZACION Y ADMINISTRACION ###

resource "azurerm_user_assigned_identity" "user_identity" {
  location            = local.location
  name                = "${local.client}-MI-Principal"
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  depends_on          = [azurerm_resource_group.rg-prod]
  tags = merge(local.tags, {
    Recurso = "Identidad administrada"
  })
}

resource "azurerm_log_analytics_workspace" "law-vm" {
  name                = "${local.client}-LAW-Principal"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = merge(local.tags, {
    Recurso = "Log Analytics Workspace"
  })

  depends_on = [azurerm_resource_group.rg-prod]
}

resource "azurerm_log_analytics_workspace" "law-vm-intune" {
  name                = "${local.client}-LAW-Intune"
  location            = local.location
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = merge(local.tags, {
    Recurso = "Log Analytics Workspace"
    Uso     = "Intune"
  })

  depends_on = [azurerm_resource_group.rg-prod]
}

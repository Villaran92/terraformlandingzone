### CUENTA DE AUTOMATIZACION ###

resource "azurerm_automation_account" "auto_account" {
  name                = "${local.client}-AutomationAccount"
  location            = "West Europe" // No disponible en Spain Central
  resource_group_name = azurerm_resource_group.rg-prod["Critical-Core"].name
  sku_name            = "Basic"
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_identity.id]
  }
  tags = merge(local.tags, {
    Recurso = "Automation Account"
  })
}

### RUNBOOKS ###

data "local_file" "policyremediation" {
  filename = "${path.module}/scripts/policyremediation.ps1"
}

resource "azurerm_automation_runbook" "policyremediation" {
  name                    = "Start-AzPolicyRemediation"
  location                = azurerm_automation_account.auto_account.location
  resource_group_name     = azurerm_automation_account.auto_account.resource_group_name
  automation_account_name = azurerm_automation_account.auto_account.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Policy Remediation"
  runbook_type            = "PowerShell72"

  content = data.local_file.policyremediation.content
}

### DSC ###

resource "azurerm_automation_dsc_configuration" "dsc1" {
  name                    = "TimeZone_SetTimeZone_Config"
  resource_group_name     = azurerm_automation_account.auto_account.resource_group_name
  automation_account_name = azurerm_automation_account.auto_account.name
  location                = azurerm_automation_account.auto_account.location
  content_embedded        = file("./scripts/TimeZone_SetTimeZone_Config.ps1")
}

resource "azurerm_automation_dsc_configuration" "dsc2" {
  name                    = "tls3"
  resource_group_name     = azurerm_automation_account.auto_account.resource_group_name
  automation_account_name = azurerm_automation_account.auto_account.name
  location                = azurerm_automation_account.auto_account.location
  content_embedded        = file("./scripts/tls3.ps1")
}

resource "azurerm_automation_dsc_configuration" "dsc3" {
  name                    = "SystemLocale_SetSystemLocale_Config"
  resource_group_name     = azurerm_automation_account.auto_account.resource_group_name
  automation_account_name = azurerm_automation_account.auto_account.name
  location                = azurerm_automation_account.auto_account.location
  content_embedded        = file("./scripts/SystemLocale_SetSystemLocale_Config.ps1")
}

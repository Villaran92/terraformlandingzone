### ROLES RECURSOS ###

resource "azurerm_role_assignment" "rolekeyvaultsecretofficer" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.tenant.object_id
}

resource "azurerm_role_assignment" "rolecontributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.user_identity.principal_id
}

resource "azurerm_role_assignment" "windowslogingroup" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = azuread_group.windowslogingroup.object_id
}

resource "azurerm_role_assignment" "keyvaultsecretgroup" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_group.keyvaultsecretgroup.object_id
}

resource "azurerm_role_assignment" "account" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Resource Policy Contributor"
  principal_id         = azurerm_automation_account.auto_account.identity[0].principal_id
}
